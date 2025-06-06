let cmi_files dir =
  Bos.OS.Dir.fold_contents ~traverse:`None ~elements:`Files
    (fun path acc ->
      if Fpath.has_ext ".cmi" path then Fpath.filename path :: acc else acc)
    [] dir

let gen_cmis cmis =
  let gen_one (dir, cmis) =
    let all_cmis =
      List.map (fun s -> String.sub s 0 (String.length s - 4)) cmis
    in
    let hidden, non_hidden =
      List.partition (fun x -> Astring.String.is_infix ~affix:"__" x) all_cmis
    in
    let prefixes =
      List.filter_map
        (fun x ->
          match Astring.String.cuts ~sep:"__" x with
          | x :: _ -> Some (x ^ "__")
          | _ -> None)
        hidden
    in
    let prefixes = Util.StringSet.(of_list prefixes |> to_list) in
    let findlib_dir = Ocamlfind.findlib_dir () |> Fpath.v in
    let d = Fpath.relativize ~root:findlib_dir dir |> Option.get in
    let dcs =
      {
        Js_top_worker_rpc.Toplevel_api_gen.dcs_url =
          Fpath.(v "lib" // d |> to_string);
        dcs_toplevel_modules = List.map String.capitalize_ascii non_hidden;
        dcs_file_prefixes = prefixes;
      }
    in
    ( dir,
      Jsonrpc.to_string
        (Rpcmarshal.marshal
           Js_top_worker_rpc.Toplevel_api_gen.typ_of_dynamic_cmis dcs) )
  in
  List.map gen_one cmis

let opam output_dir_str switch libraries no_worker =
  Opam.switch := switch;
  let libraries =
    match Ocamlfind.deps libraries with
    | Ok l -> Util.StringSet.of_list ("stdlib" :: l)
    | Error (`Msg m) ->
        Format.eprintf "Failed to find libs: %s\n%!" m;
        (* Format.eprintf "Bad libs: %s\n%!" m; *)
        (* failwith ("Bad libs: " ^ m) *)
        failwith ("Bad libs: " ^ m)
  in
  let verbose = true in
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  if verbose then Logs.set_level (Some Logs.Debug) else Logs.set_level None;
  Logs.set_reporter (Logs_fmt.reporter ());
  let () = Worker_pool.start_workers env sw 16 in
  Logs.debug (fun m ->
      m "Libraries: %a"
        (Fmt.list ~sep:Fmt.comma Fmt.string)
        (Util.StringSet.elements libraries));
  let output_dir = Fpath.v output_dir_str in
  let meta_files =
    List.map
      (fun lib -> Ocamlfind.meta_file lib)
      (Util.StringSet.elements libraries)
    |> Util.StringSet.of_list
  in
  let cmi_dirs =
    match Ocamlfind.deps (Util.StringSet.to_list libraries) with
    | Ok libs ->
        let dirs =
          List.filter_map
            (fun lib ->
              match Ocamlfind.get_dir lib with Ok x -> Some x | _ -> None)
            libs
        in
        dirs
    | Error (`Msg m) ->
        Format.eprintf "Failed to find libs: %s\n%!" m;
        []
  in
  Format.eprintf "cmi_dirs: %a\n%!" (Fmt.list ~sep:Fmt.comma Fpath.pp) cmi_dirs;
  let cmis =
    List.fold_left
      (fun acc dir ->
        match cmi_files dir with
        | Ok files -> (dir, files) :: acc
        | Error _ -> acc)
      [] cmi_dirs
  in
  let ( let* ) = Result.bind in

  let _ =
    let* _ = Bos.OS.Dir.create output_dir in
    let findlib_dir = Ocamlfind.findlib_dir () |> Fpath.v in

    List.iter
      (fun (dir, files) ->
        let d = Fpath.relativize ~root:findlib_dir dir |> Option.get in
        List.iter
          (fun f ->
            let dest_dir = Fpath.(output_dir / "lib" // d) in
            let dest = Fpath.(dest_dir / f) in
            let _ = Bos.OS.Dir.create ~path:true dest_dir in
            match Bos.OS.File.exists dest with
            | Ok true -> ()
            | Ok false -> Util.cp Fpath.(dir / f) dest
            | Error _ -> failwith "file exists failed")
          files)
      cmis;

    let meta_rels =
      Util.StringSet.fold
        (fun meta_file acc ->
          let meta_file = Fpath.v meta_file in
          let d =
            Fpath.relativize ~root:findlib_dir meta_file
            |> Option.get |> Fpath.parent
          in
          (meta_file, d) :: acc)
        meta_files []
    in

    List.iter
      (fun (meta_file, d) ->
        let dest = Fpath.(output_dir / "lib" // d) in
        let _ = Bos.OS.Dir.create dest in
        Util.cp meta_file dest)
      meta_rels;

    Out_channel.with_open_bin
      Fpath.(output_dir / "findlib_index" |> to_string)
      (fun oc ->
        List.iter
          (fun (meta_file, d) ->
            let file = Fpath.filename meta_file in
            let path = Fpath.(v "lib" // d / file) in
            Printf.fprintf oc "%s\n" (Fpath.to_string path))
          meta_rels);

    Util.StringSet.iter
      (fun lib ->
        let archives = Ocamlfind.archives lib in
        let dir = Ocamlfind.get_dir lib |> Result.get_ok in
        let archives = List.map (fun x -> Fpath.(dir / x)) archives in
        let d = Fpath.relativize ~root:findlib_dir dir |> Option.get in
        let dest = Fpath.(output_dir / "lib" // d) in
        let _ = Bos.OS.Dir.create dest in
        let doit archive =
          let output = Fpath.(dest / (Fpath.filename archive ^ ".js")) in
          let cmd =
            match switch with
            | None ->
                Bos.Cmd.(
                  v "js_of_ocaml" % "compile" % Fpath.to_string archive % "-o"
                  % Fpath.to_string output)
            | Some s ->
                Bos.Cmd.(
                  v "opam" % "exec" % "--switch" % s % "--" % "js_of_ocaml"
                  % "compile" % Fpath.to_string archive % "-o"
                  % Fpath.to_string output)
          in
          let _ = Util.lines_of_process cmd in
          ()
        in
        List.iter doit archives)
      libraries;

    (* Format.eprintf "@[<hov 2>dir: %a [%a]@]\n%!" Fpath.pp dir (Fmt.list ~sep:Fmt.sp Fmt.string) files) cmis; *)
    Ok ()
  in
  let init_cmis = gen_cmis cmis in
  List.iter
    (fun (dir, dcs) ->
      let findlib_dir = Ocamlfind.findlib_dir () |> Fpath.v in
      let d = Fpath.relativize ~root:findlib_dir dir in
      match d with
      | None ->
          Format.eprintf "Failed to relativize %a wrt %a\n%!" Fpath.pp dir
            Fpath.pp findlib_dir
      | Some dir ->
          Format.eprintf "Generating %a\n%!" Fpath.pp dir;
          let dir = Fpath.(output_dir / "lib" // dir) in
          let _ = Bos.OS.Dir.create dir in
          let oc = open_out Fpath.(dir / "dynamic_cmis.json" |> to_string) in
          Printf.fprintf oc "%s" dcs;
          close_out oc)
    init_cmis;
  Format.eprintf "Number of cmis: %d\n%!" (List.length init_cmis);

  let () =
    if no_worker then () else Mk_backend.mk switch libraries output_dir
  in

  `Ok ()

open Cmdliner

let opam_cmd =
  let libraries = Arg.(value & pos_all string [] & info [] ~docv:"LIB") in
  let output_dir =
    let doc =
      "Output directory in which to put all outputs. This should be the root \
       directory of the HTTP server"
    in
    Arg.(value & opt string "html" & info [ "o"; "output" ] ~doc)
  in
  let no_worker =
    let doc = "Do not create worker.js" in
    Arg.(value & flag & info [ "no-worker" ] ~doc)
  in
  let switch =
    let doc = "Opam switch to use" in
    Arg.(value & opt (some string) None & info [ "switch" ] ~doc)
  in
  let info = Cmd.info "opam" ~doc:"Generate opam files" in
  Cmd.v info
    Term.(ret (const opam $ output_dir $ switch $ libraries $ no_worker))

let main_cmd =
  let doc = "An odoc notebook tool" in
  let info = Cmd.info "odoc-notebook" ~version:"%%VERSION%%" ~doc in
  let default = Term.(ret (const (`Help (`Pager, None)))) in
  Cmd.group info ~default [ opam_cmd ]

let () = exit (Cmd.eval main_cmd)
