(* Simplest example *)
open Js_of_ocaml
open Js_top_worker_rpc
module W = Js_top_worker_client.W

let log s = Console.console##log (Js.string s)

let initialise s callback =
  let ( let* ) = Lwt_result.bind in
  let rpc = Js_top_worker_client.start s 10000000 callback in
  let* () =
    W.init rpc
      Toplevel_api_gen.
        { stdlib_dcs = None; findlib_requires = []; execute = true }
  in
  Lwt.return (Ok rpc)

let log_output (o : Toplevel_api_gen.exec_result) =
  Option.iter (fun s -> log ("stdout: " ^ s)) o.stdout;
  Option.iter (fun s -> log ("stderr: " ^ s)) o.stderr;
  Option.iter (fun s -> log ("sharp_ppf: " ^ s)) o.sharp_ppf;
  Option.iter (fun s -> log ("caml_ppf: " ^ s)) o.caml_ppf;
  let strloc (line, col) =
    "(" ^ string_of_int line ^ "," ^ string_of_int col ^ ")"
  in
  Option.iter
    (fun h ->
      let open Toplevel_api_gen in
      log
        ("highlight "
        ^ strloc (h.line1, h.col1)
        ^ " to "
        ^ strloc (h.line2, h.col2)))
    o.highlight

let _ =
  let ( let* ) = Lwt_result.bind in
  let* rpc = initialise "_opam/worker.js" (fun _ -> log "Timeout") in
  let* o = W.setup rpc () in
  log_output o;
  let* _o = W.query_errors rpc (Some "c1") [] false "type xxx = int;;\n" in
  let* _o2 =
    W.query_errors rpc (Some "c2") [ "c1" ] true
      "# type yyy = xxx;;\n  type yyy = xxx\n"
  in
  Lwt.return (Ok ())
