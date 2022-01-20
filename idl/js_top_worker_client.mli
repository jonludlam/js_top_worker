(* Worker_rpc *)

open Js_top_worker_rpc

(** Functions to facilitate RPC calls to web workers. *)

exception Timeout
(** When RPC calls take too long, the Lwt promise is set to failed state with
    this exception. *)

type rpc = Rpc.call -> Rpc.response Lwt.t
(** RPC function for communicating with the worker. This is used by each
    RPC function declared in {!W} *)

val start : string -> int -> (unit -> unit) -> rpc
(** [start url timeout timeout_fn] initialises a web worker from [url] and
    starts communications with it. [timeout] is the number of seconds to wait
    for a response from any RPC before raising an error, and [timeout_fn] is 
    called when a timeout occurs. Returns the {!type-rpc} function used
    in the RPC calls. *)

module W : sig
  (** {2 Type declarations}
   
  The following types are redeclared here for convenience. *)

  type init_libs = Toplevel_api_gen.init_libs
  type err = Toplevel_api_gen.err
  type exec_result = Toplevel_api_gen.exec_result
  type completion_result = Toplevel_api_gen.completion_result

  (** {2 RPC calls}
  
  The first parameter of these calls is the rpc function returned by
  {!val-start}. If any of these calls fails to receive a response from
  the worker by the timeout set in the {!val-start} call, the {!Lwt}
  thread will be {{!Lwt.fail}failed}.
  *)

  val init : rpc -> init_libs -> (unit, err) result Lwt.t
  (** Initialise the toplevel. This must be called before any other API. *)

  val setup : rpc -> unit -> (exec_result, err) result Lwt.t
  (** Start the toplevel. Return value is the initial blurb
      printed when starting a toplevel. Note that the toplevel
      must be initialised first. *)

  val exec : rpc -> string -> (exec_result, err) result Lwt.t
  (** Execute a phrase using the toplevel. The toplevel must have been
      Initialised first. *)

  val complete : rpc -> string -> (completion_result, err) result Lwt.t
  (** Find completions of the incomplete phrase. Completion occurs at the
    end of the phrase passed in. If completion is required at a point
    other than the end of a string, then take the substring before calling
    this API. *)
end
