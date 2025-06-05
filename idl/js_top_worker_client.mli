(* Worker_rpc *)

open Js_top_worker_rpc

(** Functions to facilitate RPC calls to web workers. *)

exception Timeout
(** When RPC calls take too long, the Lwt promise is set to failed state with
    this exception. *)

type rpc = Rpc.call -> Rpc.response Lwt.t
(** RPC function for communicating with the worker. This is used by each RPC
    function declared in {!W} *)

val start : string -> int -> (unit -> unit) -> rpc
(** [start url timeout timeout_fn] initialises a web worker from [url] and
    starts communications with it. [timeout] is the number of seconds to wait
    for a response from any RPC before raising an error, and [timeout_fn] is
    called when a timeout occurs. Returns the {!type-rpc} function used in the
    RPC calls. *)

module W : sig
  (** {2 Type declarations}

      The following types are redeclared here for convenience. *)

  type init_config = Toplevel_api_gen.init_config
  type err = Toplevel_api_gen.err
  type exec_result = Toplevel_api_gen.exec_result

  (** {2 RPC calls}

      The first parameter of these calls is the rpc function returned by
      {!val-start}. If any of these calls fails to receive a response from the
      worker by the timeout set in the {!val-start} call, the {!Lwt} thread will
      be {{!Lwt.fail}failed}. *)

  val init : rpc -> init_config -> (unit, err) result Lwt.t
  (** Initialise the toplevel. This must be called before any other API. *)

  val setup : rpc -> unit -> (exec_result, err) result Lwt.t
  (** Start the toplevel. Return value is the initial blurb printed when
      starting a toplevel. Note that the toplevel must be initialised first. *)

  val typecheck : rpc -> string -> (exec_result, err) result Lwt.t
  (** Typecheck a phrase using the toplevel. The toplevel must have been
      initialised first. *)

  val exec : rpc -> string -> (exec_result, err) result Lwt.t
  (** Execute a phrase using the toplevel. The toplevel must have been
      initialised first. *)

  val query_errors : rpc -> string option -> string list -> bool -> string -> (Toplevel_api_gen.error list, err) result Lwt.t
  (** Query the toplevel for errors. The first argument is the phrase to check
      for errors. If it is [None], the toplevel will return all errors. If it
      is [Some s], the toplevel will return only errors related to [s]. *)

  val compile_js : rpc -> string option -> string -> (string, err) result Lwt.t
end
