(* Unix worker *)
open Js_top_worker
open Js_top_worker_rpc.Toplevel_api_gen
open Impl

let capture : (unit -> 'a) -> unit -> Impl.captured * 'a =
 fun f () ->
  let stdout_buff = Buffer.create 1024 in
  let stderr_buff = Buffer.create 1024 in
  Js_of_ocaml.Sys_js.set_channel_flusher stdout (Buffer.add_string stdout_buff);

  let x = f () in
  let captured =
    {
      Impl.stdout = Buffer.contents stdout_buff;
      stderr = Buffer.contents stderr_buff;
    }
  in
  (captured, x)

module Server = Js_top_worker_rpc.Toplevel_api_gen.Make (Impl.IdlM.GenServer ())

module S : Impl.S = struct
  type findlib_t = Js_top_worker_web.Findlibish.t

  let capture = capture

  let sync_get f =
    let f = Fpath.v ("_opam/" ^ f) in
    Logs.info (fun m -> m "sync_get: %a" Fpath.pp f);
    try Some (In_channel.with_open_bin (Fpath.to_string f) In_channel.input_all)
    with e ->
      Logs.err (fun m ->
          m "Error reading file %a: %s" Fpath.pp f (Printexc.to_string e));
      None

  let create_file = Js_of_ocaml.Sys_js.create_file

  let import_scripts urls =
    if List.length urls > 0 then failwith "Not implemented" else ()

  let init_function _ () = failwith "Not implemented"
  let findlib_init = Js_top_worker_web.Findlibish.init sync_get

  let get_stdlib_dcs uri =
    Js_top_worker_web.Findlibish.fetch_dynamic_cmis sync_get uri
    |> Result.to_list

  let require b v = function
    | [] -> []
    | packages -> Js_top_worker_web.Findlibish.require sync_get b v packages
  
  let path = "/static/cmis"
end

module U = Impl.Make (S)

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
  let ( let* ) = IdlM.ErrM.bind in
  let init_config =
    Js_top_worker_rpc.Toplevel_api_gen.
      { stdlib_dcs = None; findlib_requires = [ "stringext" ]; execute = false }
  in
  let x =
    let open Client in
    let* _ = init rpc init_config in
    let* o = setup rpc () in
    Logs.info (fun m ->
        m "setup output: %s" (Option.value ~default:"" o.stdout));
    let* _ = query_errors rpc (Some "c1") [] false "type xxxx = int;;\n" in
    let* o1 =
      query_errors rpc (Some "c2") [ "c1" ] false "type yyy = xxx;;\n"
    in
    Logs.info (fun m -> m "Number of errors: %d" (List.length o1));
    let* _ = query_errors rpc (Some "c1") [] false "type xxx = int;;\n" in
    let* o2 =
      query_errors rpc (Some "c2") [ "c1" ] false "type yyy = xxx;;\n"
    in
    Logs.info (fun m -> m "Number of errors1: %d" (List.length o1));
    Logs.info (fun m -> m "Number of errors2: %d" (List.length o2));
    (* let* o3 =
      Client.exec_toplevel rpc
        "# Stringext.of_list ['a';'b';'c'];;\n" in
    Logs.info (fun m -> m "Exec toplevel output: %s" o3.script); *)
    IdlM.ErrM.return ()
  in
  match x |> IdlM.T.get |> M.run with
  | Ok () -> Logs.info (fun m -> m "Success")
  | Error (InternalError s) -> Logs.err (fun m -> m "Error: %s" s)
