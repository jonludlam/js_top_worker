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

  let path = "/tmp/cmis"
end

module U = Impl.Make (S)

let start_server () =
  (try Unix.mkdir S.path 0o777 with Unix.Unix_error (Unix.EEXIST, _, _) -> ());
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

let c1, c2, c3, c4 = "c1", "c2", "c3", "c4"
let notebook = [
  (c1,[],"typ xxxx = int;;\n");
  (c2,[c1],"type yyy=xxx;;\n");
  (c3,[c1;c2],"type xxx = int;;\n");
  (c4,[c1;c2;c3],"type yyy = xxx;;\n");
]

let _ =
  let rpc = start_server () in
  Printf.printf "Starting worker...\n%!";
  let ( let* ) = IdlM.ErrM.bind in
  let init =
    Js_top_worker_rpc.Toplevel_api_gen.
      { stdlib_dcs = None; findlib_requires = []; execute = true }
  in
  let x =
    let rec run notebook =
      match notebook with
      | (id, deps, cell) :: cells ->
        let* errs = Client.query_errors rpc (Some id) deps false cell in
        Printf.printf "Cell %s: %d errors\n%!" id (List.length errs);
        run cells
      | [] -> IdlM.ErrM.return ()
    in  
    let* _ = Client.init rpc init in
    let* _ = Client.setup rpc () in
    let* _ = run notebook in
    IdlM.ErrM.return ()
  in
  match x |> IdlM.T.get |> M.run with
  | Ok () -> Printf.printf "Success\n%!"
  | Error (InternalError s) -> Printf.printf "Error: %s\n%!" s
