(* Unix worker *)
open Js_top_worker
open Impl

let capture : (unit -> 'a) -> unit -> Impl.captured * 'a =
   fun f () ->
    let stdout_buff = Buffer.create 1024 in
    let stderr_buff = Buffer.create 1024 in
    Js_of_ocaml.Sys_js.set_channel_flusher stdout
      (Buffer.add_string stdout_buff);
    Js_of_ocaml.Sys_js.set_channel_flusher stderr
      (Buffer.add_string stderr_buff);
    let x = f () in
    let captured =
      {
        Impl.stdout = Buffer.contents stdout_buff;
        stderr = Buffer.contents stderr_buff;
      }
    in
    (captured, x)

let handle_findlib_error = function
  | Failure msg -> Printf.fprintf stderr "%s" msg
  | Fl_package_base.No_such_package (pkg, reason) ->
      Printf.fprintf stderr "No such package: %s%s\n" pkg
        (if reason <> "" then " - " ^ reason else "")
  | Fl_package_base.Package_loop pkg ->
      Printf.fprintf stderr "Package requires itself: %s\n" pkg
  | exn -> raise exn

module Server = Js_top_worker_rpc.Toplevel_api_gen.Make (Impl.IdlM.GenServer ())

module S : Impl.S = struct
  type findlib_t = unit

  let capture = capture
  let sync_get _ = None
  let create_file = Js_of_ocaml.Sys_js.create_file

  let import_scripts urls =
    if List.length urls > 0 then failwith "Not implemented" else ()

  let init_function _ () = failwith "Not implemented"
  let findlib_init _ = ()
  let get_stdlib_dcs _uri = []

  let require () packages =
    try
      let eff_packages =
        Findlib.package_deep_ancestors !Topfind.predicates packages
      in
      Topfind.load eff_packages;
      []
    with exn ->
      handle_findlib_error exn;
      []
end

module U = Impl.Make (S)

(* let test () =
  let _x = Compmisc.initial_env in
  let oc = open_out "/tmp/unix_worker.ml" in
  Printf.fprintf oc "let x=1;;\n";
  close_out oc;
  let unit_info = Unit_info.make ~source_file:"/tmp/unix_worker.ml" "/tmp/unix_worker" in
  try
    let _ast = Pparse.parse_implementation ~tool_name:"worker" "/tmp/unix_worker.ml" in
    let _ = Typemod.type_implementation unit_info (Compmisc.initial_env ()) _ast in
    ()
  with exn ->
    Printf.eprintf "error: %s\n%!" (Printexc.to_string exn);
    let ppf = Format.err_formatter in
    let _ = Location.report_exception ppf exn in
    () *)

let start_server () =
  let open U in
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  (* let pid = Unix.getpid () in *)
  Server.exec execute;
  Server.setup setup;
  Server.init init;
  Server.typecheck typecheck_phrase;
  Server.complete_prefix complete_prefix;
  Server.query_errors query_errors;
  Server.type_enclosing type_enclosing;
  Server.compile_js compile_js;
  Server.exec_toplevel exec_toplevel;
  IdlM.server Server.implementation

module Client = Js_top_worker_rpc.Toplevel_api_gen.Make (Impl.IdlM.GenClient ())

let _ =
  let rpc = start_server () in
  Printf.printf "Starting worker...\n%!";
  let ( let* ) = IdlM.ErrM.bind in
  let dcs =
    Js_top_worker_rpc.Toplevel_api_gen.
      {
        dcs_url = "cmis/";
        dcs_toplevel_modules =
          [
            "CamlinternalOO";
            "Stdlib";
            "CamlinternalFormat";
            "Std_exit";
            "CamlinternalMod";
            "CamlinternalFormatBasics";
            "CamlinternalLazy";
          ];
        dcs_file_prefixes = [ "stdlib__" ];
      }
  in
  let init =
    Js_top_worker_rpc.Toplevel_api_gen.
      {
        path = "/tmp/static/cmis";
        cmas = [];
        cmis = { dynamic_cmis = [ dcs ]; static_cmis = [] };
        stdlib_dcs = "/lib/ocaml/dynamic_cmis.json";
        findlib_index = "/lib/findlib_index";
        findlib_requires = [];
      }
  in
  let x =
    let* _ = Client.init rpc init in
    let* o = Client.setup rpc () in
    Printf.printf "setup output: %s\n%!" (Option.value ~default:"" o.stdout);
    let* _ =
      Client.query_errors rpc (Some "c1") [] false "typ xxxx = int;;\n"
    in
    let* o1 =
      Client.query_errors rpc (Some "c2") ["c1"] false "type yyy = xxx;;\n"
    in
    Printf.printf "Number of errors: %d\n%!" (List.length o1);
    let* _ =
      Client.query_errors rpc (Some "c1") [] false "type xxx = int;;\n"
    in
    let* o2 =
      Client.query_errors rpc (Some "c2") ["c1"] false
        "type yyy = xxx;;\n"
    in
    Printf.printf "Number of errors1: %d\n%!" (List.length o1);
    Printf.printf "Number of errors2: %d\n%!" (List.length o2);
    IdlM.ErrM.return ()
  in
  match x |> IdlM.T.get |> M.run with
  | Ok () -> Printf.printf "Success\n%!"
  | Error (InternalError s) -> Printf.printf "Error: %s\n%!" s
