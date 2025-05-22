(** Worker rpc *)

(** Functions to facilitate RPC calls to web workers. *)

module Worker = Brr_webworkers.Worker
open Brr_io
open Js_top_worker_rpc

(** The assumption made in this module is that RPCs are answered in the order
    they are made. *)

type context = {
  worker : Worker.t;
  timeout : int;
  timeout_fn : unit -> unit;
  waiting : (((Rpc.response, exn) Result.t -> unit) * int) Queue.t;
}

type rpc = Rpc.call -> Rpc.response Fut.t

exception Timeout

(* let log s = Js_of_ocaml.Firebug.console##log (Js_of_ocaml.Js.string s) *)

let demux context msg =
  match Queue.take_opt context.waiting with
  | None -> ()
  | Some (mv, outstanding_execution) ->
      Brr.G.stop_timer outstanding_execution;
      let msg = Message.Ev.data (Brr.Ev.as_type msg) in
      let msg = Js_of_ocaml.Js.to_string msg in
      (* log (Printf.sprintf "Client received: %s" msg); *)
      mv (Ok (Jsonrpc.response_of_string msg))

let rpc : context -> Rpc.call -> Rpc.response Fut.t =
 fun context call ->
  let open Fut.Syntax in
  let jv = Jsonrpc.string_of_call call |> Js_of_ocaml.Js.string in
  (* log (Printf.sprintf "Client sending: %s" jv); *)
  let v, mv = Fut.create () in
  let outstanding_execution =
    Brr.G.set_timeout ~ms:context.timeout (fun () ->
        mv (Error Timeout);
        Worker.terminate context.worker;
        context.timeout_fn ())
  in
  Queue.push (mv, outstanding_execution) context.waiting;
  Worker.post context.worker jv;
  let* r = v in
  match r with
  | Ok jv ->
      let response = jv in
      Fut.return response
  | Error exn -> raise exn

let start url timeout timeout_fn : rpc =
  let worker = Worker.create (Jstr.v url) in
  let context = { worker; timeout; timeout_fn; waiting = Queue.create () } in
  let _listener =
    Brr.Ev.listen Message.Ev.message (demux context) (Worker.as_target worker)
  in
  rpc context

module M = struct
  include Fut

  let fail e = raise e
end

module Rpc_fut = Idl.Make (M)
module Wraw = Toplevel_api_gen.Make (Rpc_fut.GenClient ())

module W = struct
  type init_libs = Toplevel_api_gen.init_libs
  type err = Toplevel_api_gen.err
  type exec_result = Toplevel_api_gen.exec_result

  let init rpc a = Wraw.init rpc a |> Rpc_fut.T.get
  let setup rpc a = Wraw.setup rpc a |> Rpc_fut.T.get
  let typecheck rpc a = Wraw.typecheck rpc a |> Rpc_fut.T.get
  let exec rpc a = Wraw.exec rpc a |> Rpc_fut.T.get
  let compile_js rpc id s = Wraw.compile_js rpc id s |> Rpc_fut.T.get
  let query_errors rpc id deps is_toplevel doc = Wraw.query_errors rpc id deps is_toplevel doc |> Rpc_fut.T.get
  let exec_toplevel rpc doc = Wraw.exec_toplevel rpc doc |> Rpc_fut.T.get

  let complete_prefix rpc id deps is_toplevel doc pos =
    Wraw.complete_prefix rpc id deps is_toplevel doc pos |> Rpc_fut.T.get

  let type_enclosing rpc id deps is_toplevel doc pos =
    Wraw.type_enclosing rpc id deps is_toplevel doc pos |> Rpc_fut.T.get
end
