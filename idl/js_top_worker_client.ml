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
  waiting : ((Rpc.response, exn) Result.t Lwt_mvar.t * int) Queue.t;
}

type rpc = Rpc.call -> Rpc.response Lwt.t

exception Timeout

let demux context msg =
  Lwt.async (fun () ->
      match Queue.take_opt context.waiting with
      | None -> Lwt.return ()
      | Some (mv, outstanding_execution) ->
          Brr.G.stop_timer outstanding_execution;
          let msg : string = Message.Ev.data (Brr.Ev.as_type msg) in
          Lwt_mvar.put mv (Ok (Marshal.from_string msg 0)))

let rpc : context -> Rpc.call -> Rpc.response Lwt.t =
 fun context call ->
  let open Lwt in
  let jv = Marshal.to_bytes call [] in
  let mv = Lwt_mvar.create_empty () in
  let outstanding_execution =
    Brr.G.set_timeout ~ms:context.timeout (fun () ->
        Lwt.async (fun () -> Lwt_mvar.put mv (Error Timeout));
        Worker.terminate context.worker;
        context.timeout_fn ())
  in
  Queue.push (mv, outstanding_execution) context.waiting;
  Worker.post context.worker jv;
  Lwt_mvar.take mv >>= fun r ->
  match r with
  | Ok jv ->
      let response = jv in
      Lwt.return response
  | Error exn -> Lwt.fail exn

let start url timeout timeout_fn : rpc =
  let worker = Worker.create (Jstr.v url) in
  let context = { worker; timeout; timeout_fn; waiting = Queue.create () } in
  let () =
    Brr.Ev.listen Message.Ev.message (demux context) (Worker.as_target worker)
  in
  rpc context

module Rpc_lwt = Idl.Make (Lwt)
module Wraw = Toplevel_api_gen.Make (Rpc_lwt.GenClient ())

module W : sig
  type init_libs = Toplevel_api_gen.init_libs
  type err = Toplevel_api_gen.err
  type exec_result = Toplevel_api_gen.exec_result
  type completion_result = Toplevel_api_gen.completion_result

  val init :
    rpc ->
    Toplevel_api_gen.init_libs ->
    (unit, Toplevel_api_gen.err) result Lwt.t

  val setup :
    rpc ->
    unit ->
    (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) result Lwt.t

  val typecheck :
    rpc ->
    string ->
    (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) result Lwt.t

  val exec :
    rpc ->
    string ->
    (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) result Lwt.t

  val complete :
    rpc ->
    string ->
    (Toplevel_api_gen.completion_result, Toplevel_api_gen.err) result Lwt.t
end = struct
  type init_libs = Toplevel_api_gen.init_libs
  type err = Toplevel_api_gen.err
  type exec_result = Toplevel_api_gen.exec_result
  type completion_result = Toplevel_api_gen.completion_result

  let init rpc a = Wraw.init rpc a |> Rpc_lwt.T.get
  let setup rpc a = Wraw.setup rpc a |> Rpc_lwt.T.get
  let typecheck rpc a = Wraw.typecheck rpc a |> Rpc_lwt.T.get
  let exec rpc a = Wraw.exec rpc a |> Rpc_lwt.T.get
  let complete rpc a = Wraw.complete rpc a |> Rpc_lwt.T.get
end
