(* Kinda findlib, sorta *)

type library = {
  name : string;
  meta_uri : Uri.t;
  archive_name : string option;
  dir : string option;
  deps : string list;
  children : library list;
  mutable loaded : bool;
}

let rec flatten_libs libs =
  let handle_lib l =
    let children = flatten_libs l.children in
    l :: children
  in
  List.map handle_lib libs |> List.flatten

let preloaded =
  [
    "logs";
    "js_top_worker-rpc";
    "js_of_ocaml-compiler";
    "js_of_ocaml-ppx";
    "astring";
    "mime_printer";
    "compiler-libs.common";
    "compiler-libs.toplevel";
    "merlin-lib.kernel";
    "merlin-lib.utils";
    "merlin-lib.query_protocol";
    "merlin-lib.query_commands";
    "merlin-lib.ocaml_parsing";
    "findlib";
    "findlib.top";
    "js_top_worker";
    "js_of_ocaml-ppx";
    "js_of_ocaml-toplevel";
    "logs.browser";
    "uri";
    "angstrom";
    "findlib";
    "fpath";
  ]

let rec read_libraries_from_pkg_defs ~library_name ~dir meta_uri pkg_expr =
  try
    let pkg_defs = pkg_expr.Fl_metascanner.pkg_defs in
    let archive_filename =
      try Some (Fl_metascanner.lookup "archive" [ "byte" ] pkg_defs)
      with _ -> (
        try Some (Fl_metascanner.lookup "archive" [ "native" ] pkg_defs)
        with _ -> None)
    in

    let deps_str = Fl_metascanner.lookup "requires" [] pkg_defs in
    let deps = Astring.String.fields ~empty:false deps_str in
    let subdir =
      List.find_opt (fun d -> d.Fl_metascanner.def_var = "directory") pkg_defs
      |> Option.map (fun d -> d.Fl_metascanner.def_value)
    in
    let dir =
      match (dir, subdir) with
      | None, None -> None
      | Some d, None -> Some d
      | None, Some d -> Some d
      | Some d1, Some d2 -> Some (Filename.concat d1 d2)
    in
    let archive_name =
      Option.bind archive_filename (fun a ->
          let file_name_len = String.length a in
          if file_name_len > 0 then Some (Filename.chop_extension a) else None)
    in
    let children =
      List.filter_map
        (fun (n, expr) ->
          let library_name = library_name ^ "." ^ n in
          match
            read_libraries_from_pkg_defs ~library_name ~dir meta_uri expr
          with
          | Ok l -> Some l
          | Error (`Msg m) ->
              Jslib.log "Error reading sub-library: %s" m;
              None)
        pkg_expr.pkg_children
    in
    Ok
      {
        name = library_name;
        archive_name;
        dir;
        deps;
        meta_uri;
        loaded = false;
        children;
      }
  with Not_found -> Error (`Msg "Failed to read libraries from pkg_defs")

type t = library list

let dcs_filename = "dynamic_cmis.json"

let fetch_dynamic_cmis sync_get url =
  match sync_get url with
  | None -> Error (`Msg "Failed to fetch dynamic cmis")
  | Some json ->
      let rpc = Jsonrpc.of_string json in
      Rpcmarshal.unmarshal
        Js_top_worker_rpc.Toplevel_api_gen.typ_of_dynamic_cmis rpc

let init sync_get findlib_index : t =
  let findlib_metas =
    match sync_get findlib_index with
    | None -> []
    | Some txt -> Astring.String.fields ~empty:false txt
  in
  let metas =
    List.filter_map
      (fun x ->
        match sync_get x with Some meta -> Some (x, meta) | None -> None)
      findlib_metas
  in
  List.filter_map
    (fun (x, meta) ->
      match Angstrom.parse_string ~consume:All Uri.Parser.uri_reference x with
      | Ok uri -> (
          Jslib.log "Parsed uri: %s" (Uri.path uri);
          let path = Uri.path uri in
          let file = Fpath.v path in
          let base_library_name =
            if Fpath.basename file = "META" then
              Fpath.parent file |> Fpath.basename
            else Fpath.get_ext file
          in

          let lexing = Lexing.from_string meta in
          try
            let meta = Fl_metascanner.parse_lexing lexing in
            let libraries =
              read_libraries_from_pkg_defs ~library_name:base_library_name
                ~dir:None uri meta
            in
            Result.to_option libraries
          with _ ->
            Jslib.log "Failed to parse meta: %s" (Uri.path uri);
            None)
      | Error m ->
          Jslib.log "Failed to parse uri: %s" m;
          None)
    metas
  |> flatten_libs

let require sync_get cmi_only v packages =
  let rec require dcss package :
      Js_top_worker_rpc.Toplevel_api_gen.dynamic_cmis list =
    match List.find (fun lib -> lib.name = package) v with
    | exception Not_found ->
        Jslib.log "Package %s not found" package;
        dcss
    | lib ->
        if lib.loaded then dcss
        else (
          Jslib.log "Loading package %s" lib.name;
          Jslib.log "lib.dir: %s" (Option.value ~default:"None" lib.dir);
          let dep_dcs = List.fold_left require dcss lib.deps in
          let path = Fpath.(v (Uri.path lib.meta_uri) |> parent) in
          let dir =
            match lib.dir with None -> path | Some d -> Fpath.(path // v d)
          in
          let dcs = Fpath.(dir / dcs_filename |> to_string) in
          let uri = Uri.with_path lib.meta_uri dcs in
          Jslib.log "uri: %s" (Uri.to_string uri);
          match fetch_dynamic_cmis sync_get (Uri.to_string uri) with
          | Ok dcs ->
              let () =
                match lib.archive_name with
                | None -> ()
                | Some archive ->
                    let archive_js =
                      Fpath.(dir / (archive ^ ".cma.js") |> to_string)
                    in
                    if List.mem lib.name preloaded || cmi_only then ()
                    else
                      Js_of_ocaml.Worker.import_scripts
                        [ Uri.with_path uri archive_js |> Uri.to_string ];
                    lib.loaded <- true
              in
              Jslib.log "Finished loading package %s" lib.name;
              dcs :: dep_dcs
          | Error (`Msg m) ->
              Jslib.log "Failed to unmarshal dynamic_cms from url %s: %s"
                (Uri.to_string uri) m;
              dcss)
  in
  List.fold_left require [] packages
