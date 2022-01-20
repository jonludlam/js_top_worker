(* Worker_rpc *)

open Js_top_worker_rpc

(** Functions to facilitate RPC calls to web workers. *)

exception Timeout
(** When RPC calls take too long, the Lwt promise is set to failed state with
    this exception. *)

type rpc = Rpc.call -> Rpc.response Lwt.t

val start : string -> int -> (unit -> unit) -> rpc
(** [start url timeout timeout_fn] initialises a web worker from [url] and
    starts communications with it. [timeout] is the number of seconds to wait
    for a response from any RPC before raising an error, and [timeout_fn] is 
    called when a timeout occurs. *)

module W : sig
  val init :
    rpc ->
    Toplevel_api_gen.init_libs ->
    (unit, Toplevel_api_gen.err) result Lwt.t

  val setup :
    rpc ->
    unit ->
    (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) result Lwt.t

  val exec :
    rpc ->
    string ->
    (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) result Lwt.t

  val complete :
    rpc ->
    string ->
    (Toplevel_api_gen.completion_result, Toplevel_api_gen.err) result Lwt.t
end
