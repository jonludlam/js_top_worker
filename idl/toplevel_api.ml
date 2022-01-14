(** IDL for talking to the toplevel webworker *)

open Rpc
open Idl

type highlight = { line1 : int; line2 : int; col1 : int; col2 : int }
[@@deriving rpcty]
(** An area to be highlighted *)

type exec_result = {
  stdout : string option;
  stderr : string option;
  sharp_ppf : string option;
  caml_ppf : string option;
  highlight : highlight option;
}
[@@deriving rpcty]
(** Represents the result of executing a toplevel phrase *)

type completion_result = {
  n : int;
      (** The position in the input string from where the completions may be
            inserted *)
  completions : string list;  (** The list of possible completions *)
}
[@@deriving rpcty]
(** The result returned by a 'complete' call. *)

type string_list = string list [@@deriving rpcty]
(** Used by setup *)

type string_string_list = (string * string) list [@@deriving rpcty]
(** Used by setup *)

(** For now we are only using a simple error type *)
type err = InternalError of string [@@deriving rpcty]

module E = Idl.Error.Make (struct
  type t = err

  let t = err
  let internal_error_of e = Some (InternalError (Printexc.to_string e))
end)

let err = E.error

module Make (R : RPC) = struct
  open R

  let description =
    Interface.
      {
        name = "Toplevel";
        namespace = None;
        description =
          [ "Functions for manipulating the toplevel worker thread" ];
        version = (1, 0, 0);
      }

  let implementation = implement description
  let unit_p = Param.mk Types.unit
  let phrase_p = Param.mk Types.string
  let exec_result_p = Param.mk exec_result
  let completion_p = Param.mk completion_result

  let cmas =
    Param.mk ~name:"cmas"
      ~description:
        [
          "A list of pairs. The first element of the pair is a urls to a";
          "cma file pre-compiled to javascript. The second item is the";
          "name of the function to be invoked to load the cma file";
          "(ie, the cma was compiled with --wrap-func).";
          "These will be loaded synchronously during the init call.";
        ]
      string_string_list

  let cmis =
    Param.mk ~name:"cmis"
      ~description:
        [
          "A list of urls of cmi files. These files will be loaded on demand";
          "during evaluation of toplevel phrases.";
        ]
      string_list

  let init =
    declare "init"
      [ "Initialise the toplevel." ]
      (cmas @-> cmis @-> returning unit_p err)

  let setup =
    declare "setup"
      [
        "Start the toplevel. Return value is the initial blurb ";
        "printed when starting a toplevel. Note that the toplevel";
        "must be initialised first.";
      ]
      (unit_p @-> returning exec_result_p err)

  let exec =
    declare "exec"
      [
        "Execute a phrase using the toplevel. The toplevel must have been";
        "Initialised first.";
      ]
      (phrase_p @-> returning exec_result_p err)

  let complete =
    declare "complete"
      [
        "Find completions of the incomplete phrase. Completion occurs at the";
        "end of the phrase passed in. If completion is required at a point";
        "other than the end of a string, then take the substring before calling";
        "this API.";
      ]
      (phrase_p @-> returning completion_p err)
end
