(* To make a toplevel backend.js *)

let mk switch libs dir =
  let txt = {|let _ = Js_top_worker_web.Worker.run ()|} in
  let file = Fpath.(dir / "worker.ml") in
  Util.write_file file [ txt ];
  let ocamlfind_cmd, js_of_ocaml_cmd =
    match switch with
    | None -> (Bos.Cmd.(v "ocamlfind"), Bos.Cmd.(v "js_of_ocaml"))
    | Some s ->
        ( Bos.Cmd.(v "opam" % "exec" % "--switch" % s % "--" % "ocamlfind"),
          Bos.Cmd.(v "opam" % "exec" % "--switch" % s % "--" % "js_of_ocaml") )
  in
  let cmd =
    Bos.Cmd.(
      ocamlfind_cmd % "ocamlc" % "-package" % "js_of_ocaml-ppx.as-lib"
      % "-package" % "js_top_worker-web")
  in
  let cmd = Bos.Cmd.(cmd % "-linkpkg" % "-linkall" % Fpath.to_string file) in
  let cmd =
    Bos.Cmd.(cmd % "-g" % "-o" % Fpath.(dir / "worker.bc" |> to_string))
  in
  let _ = Util.lines_of_process cmd in
  let cmd =
    Bos.Cmd.(
      ocamlfind_cmd % "query" % "-format" % "%+(jsoo_runtime)" % "-r"
      % "js_top_worker-web")
  in
  let cmd = Util.StringSet.fold (fun lib cmd -> Bos.Cmd.(cmd % lib)) libs cmd in
  let js_files =
    Util.lines_of_process cmd
    |> List.filter (fun x -> String.length x > 0)
    |> List.map (fun x -> Astring.String.cuts ~sep:" " x)
    |> List.flatten
  in
  let cmd =
    Bos.Cmd.(
      js_of_ocaml_cmd % "--toplevel" % "--no-cmis" % "--linkall" % "--pretty")
  in
  let cmd =
    List.fold_right
      (fun a cmd -> Bos.Cmd.(cmd % a))
      (js_files
      @ [
          "+dynlink.js";
          "+toplevel.js";
          "+bigstringaf/runtime.js";
          "+js_top_worker/stubs.js";
        ])
      cmd
  in
  let cmd =
    Bos.Cmd.(
      cmd
      % Fpath.(dir / "worker.bc" |> to_string)
      % "-o"
      % Fpath.(dir / "worker.js" |> to_string))
  in
  Logs.info (fun m -> m "cmd: %s" (Bos.Cmd.to_string cmd));
  let _ = Util.lines_of_process cmd in
  let to_delete = [ "worker.bc"; "worker.ml"; "worker.cmi"; "worker.cmo" ] in
  let results =
    List.map (fun f -> Bos.OS.File.delete Fpath.(dir / f)) to_delete
  in
  ignore results;
  ()
