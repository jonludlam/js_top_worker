(* Unix worker *)
open Js_top_worker
open Impl

let capture f () =
  let stdout_backup = Unix.dup ~cloexec:true Unix.stdout in
  let stderr_backup = Unix.dup ~cloexec:true Unix.stderr in
  let filename_out = Filename.temp_file "ocaml-mdx-" ".stdout" in
  let filename_err = Filename.temp_file "ocaml-mdx-" ".stderr" in
  let fd_out =
    Unix.openfile filename_out
      Unix.[ O_WRONLY; O_CREAT; O_TRUNC; O_CLOEXEC ]
      0o600
  in
  let fd_err =
    Unix.openfile filename_err
      Unix.[ O_WRONLY; O_CREAT; O_TRUNC; O_CLOEXEC ]
      0o600
  in
  Unix.dup2 ~cloexec:false fd_out Unix.stdout;
  Unix.dup2 ~cloexec:false fd_err Unix.stderr;
  let ic_out = open_in filename_out in
  let ic_err = open_in filename_err in
  let capture oc ic fd buf =
    flush oc;
    let len = Unix.lseek fd 0 Unix.SEEK_CUR in
    Buffer.add_channel buf ic len
  in
  Fun.protect
    (fun () ->
      let x = f () in
      let buf_out = Buffer.create 1024 in
      let buf_err = Buffer.create 1024 in
      capture stdout ic_out fd_out buf_out;
      capture stderr ic_err fd_err buf_err;
      ( {
          Impl.stdout = Buffer.contents buf_out;
          stderr = Buffer.contents buf_err;
        },
        x ))
    ~finally:(fun () ->
      close_in_noerr ic_out;
      close_in_noerr ic_out;
      Unix.close fd_out;
      Unix.close fd_err;
      Unix.dup2 ~cloexec:false stdout_backup Unix.stdout;
      Unix.dup2 ~cloexec:false stderr_backup Unix.stderr;
      Unix.close stdout_backup;
      Unix.close stderr_backup;
      Sys.remove filename_out;
      Sys.remove filename_err)

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
  let create_file ~name:_ ~content:_ = failwith "Not implemented"

  let import_scripts urls =
    if List.length urls > 0 then failwith "Not implemented" else ()

  let init_function _ () = failwith "Not implemented"
  let findlib_init _ = ()
  let get_stdlib_dcs _uri = []

  let require _ () packages =
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
  let init =
    Js_top_worker_rpc.Toplevel_api_gen.
      {
        stdlib_dcs = "/lib/ocaml/dynamic_cmis.json";
        findlib_index = "/lib/findlib_index";
        findlib_requires = [];
        execute = true;
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
