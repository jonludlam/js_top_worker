(** Worker rpc *)

(** Functions to facilitate RPC calls to web workers. *)

module Worker = Brr_webworkers.Worker
open Brr_io
open Js_top_worker_rpc

(** The assumption made in this module is that RPCs are answered in the order
    they are made. *)

type encoding = Jsonrpc | Marshal

type transport = Worker of Worker.t | Websocket of Websocket.t

type context = {
  transport : transport;
  encoding : encoding;
  timeout : int;
  timeout_fn : unit -> unit;
  waiting : ((Rpc.response, exn) Result.t Lwt_mvar.t * int) Queue.t;
}

type rpc = Rpc.call -> Rpc.response Lwt.t

exception Timeout

let demux context msg =
  Lwt.async (fun () ->
      Brr.Console.log [msg];
      match Queue.take_opt context.waiting with
      | None -> Lwt.return ()
      | Some (mv, outstanding_execution) ->
          Brr.G.stop_timer outstanding_execution;
          let response =
            match context.encoding with
            | Marshal ->
              let msg  = Message.Ev.data (Brr.Ev.as_type msg) in
              Marshal.from_string msg 0
            | Jsonrpc ->
              let msg  = Message.Ev.data (Brr.Ev.as_type msg) in
              Jsonrpc.response_of_string (Jstr.to_string msg)
          in
          Lwt_mvar.put mv (Ok response))

let terminate context =
  match context.transport with
  | Worker w -> Worker.terminate w
  | Websocket w -> Websocket.close w

let rpc : context -> Rpc.call -> Rpc.response Lwt.t =
 fun context call ->
  let open Lwt in
  let encoded_call = match context.encoding with
    | Marshal -> Marshal.to_string call []
    | Jsonrpc -> Jsonrpc.string_of_call call 
  in
  let mv = Lwt_mvar.create_empty () in
  let outstanding_execution =
    Brr.G.set_timeout ~ms:context.timeout (fun () ->
        Lwt.async (fun () -> Lwt_mvar.put mv (Error Timeout));
        terminate context;
        context.timeout_fn ())
  in
  Queue.push (mv, outstanding_execution) context.waiting;
  (match context.transport with
  | Worker w -> Lwt.return @@ Worker.post w encoded_call;
  | Websocket w ->
    if Websocket.ready_state w = Websocket.Ready_state.open' then
    Lwt.return @@ Websocket.send_string w (Jstr.v encoded_call)
    else begin
      let p, r = Lwt.wait () in
      Brr.Ev.listen Brr.Ev.open' (fun _ -> Lwt.wakeup_later r ()) (Brr_io.Websocket.as_target w);
      p >>= fun () -> Lwt.return @@ Websocket.send_string w (Jstr.v encoded_call)
    end) >>= fun () ->
  Lwt_mvar.take mv >>= fun r ->
  match r with
  | Ok jv ->
      let response = jv in
      Lwt.return response
  | Error exn -> Lwt.fail exn

let start url timeout timeout_fn : rpc =
  let worker = Worker.create (Jstr.v url) in
  let context = { transport = Worker worker; encoding = Marshal; timeout; timeout_fn; waiting = Queue.create () } in
  let () =
    Brr.Ev.listen Message.Ev.message (demux context) (Worker.as_target worker)
  in
  rpc context

let start_websocket url timeout timeout_fn : rpc =
  let ws = Websocket.create (Jstr.v url) in
  let context = { transport = Websocket ws; encoding = Jsonrpc; timeout; timeout_fn; waiting = Queue.create () } in
  let () =
    Brr.Ev.listen Message.Ev.message (demux context) (Websocket.as_target ws)
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
