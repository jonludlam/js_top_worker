(** IDL for talking to the toplevel webworker *)

open Rpc
open Idl

let sockpath = "/tmp/js_top_worker.sock"

open Merlin_kernel
module Location = Ocaml_parsing.Location

type lexing_position = Lexing.position = {
  pos_fname: string;
  pos_lnum: int;
  pos_bol: int;
  pos_cnum: int;
} [@@deriving rpcty]

type location = Location.t = {
  loc_start: lexing_position;
  loc_end: lexing_position;
  loc_ghost: bool;
} [@@deriving rpcty]

type location_error_source = Location.error_source =
  | Lexer
  | Parser
  | Typer
  | Warning
  | Unknown
  | Env
  | Config [@@deriving rpcty]

type location_report_kind = Location.report_kind =
  | Report_error
  | Report_warning of string
  | Report_warning_as_error of string
  | Report_alert of string
  | Report_alert_as_error of string [@@deriving rpcty]

type source = string [@@deriving rpcty]

(** CMIs are provided either statically or as URLs to be downloaded on demand *)

(** Dynamic cmis are loaded from beneath the given url. In addition the
    top-level modules are specified, and prefixes for other modules. For
    example, for the OCaml standard library, a user might pass:

    {[
      { dcs_url="/static/stdlib";
        dcs_toplevel_modules=["Stdlib"];
        dcs_file_prefixes=["stdlib__"]; }
    ]}

    In which case, merlin will expect to be able to download a valid file
    from the url ["/static/stdlib/stdlib.cmi"] corresponding to the
    specified toplevel module, and it will also attempt to download any
    module with the prefix ["Stdlib__"] from the same base url, so for
    example if an attempt is made to look up the module ["Stdlib__Foo"]
    then merlin-js will attempt to download a file from the url
    ["/static/stdlib/stdlib__Foo.cmi"].
    *)

type dynamic_cmis = {
  dcs_url : string;
  dcs_toplevel_modules : string list;
  dcs_file_prefixes : string list;
}

and static_cmi = {
  sc_name : string; (* capitalised, e.g. 'Stdlib' *)
  sc_content : string;
}

and cmis = {
  static_cmis : static_cmi list;
  dynamic_cmis : dynamic_cmis list;
} [@@deriving rpcty]

type action =
  | Complete_prefix of source * Msource.position
  | Type_enclosing of source * Msource.position
  | All_errors of source
  | Add_cmis of cmis

type error = {
  kind : location_report_kind;
  loc: location;
  main : string;
  sub : string list;
  source : location_error_source;
} [@@deriving rpcty]

type error_list = error list [@@deriving rpcty]

type kind_ty =
   Constructor
  | Keyword
  | Label
  | MethodCall
  | Modtype
  | Module 
  | Type
  | Value
  | Variant [@@deriving rpcty]

  type query_protocol_compl_entry = {
    name: string;
    kind: kind_ty;
    desc: string;
    info: string;
    deprecated: bool;
  } [@@deriving rpcty]


type completions = {
  from: int;
  to_: int;
  entries : query_protocol_compl_entry list
} [@@deriving rpcty]

type msource_position =
  | Start
  | Offset of int
  | Logical of int * int
  | End [@@deriving rpcty]

type is_tail_position =
  | No | Tail_position | Tail_call [@@deriving rpcty]

type index_or_string =
  | Index of int
  | String of string [@@deriving rpcty]


type typed_enclosings = location * index_or_string * is_tail_position [@@deriving rpcty]
type typed_enclosings_list = typed_enclosings list [@@deriving rpcty]
let report_source_to_string = function
  | Location.Lexer   -> "lexer"
  | Location.Parser  -> "parser"
  | Location.Typer   -> "typer"
  | Location.Warning -> "warning" (* todo incorrect ?*)
  | Location.Unknown -> "unknown"
  | Location.Env     -> "env"
  | Location.Config  -> "config"

type highlight = { line1 : int; line2 : int; col1 : int; col2 : int }
[@@deriving rpcty]
(** An area to be highlighted *)
type encoding = Mime_printer.encoding = | Noencoding | Base64 [@@deriving rpcty]

type mime_val = Mime_printer.t = {
  mime_type : string;
  encoding : encoding;
  data : string;
}
[@@deriving rpcty]

type exec_result = {
  stdout : string option;
  stderr : string option;
  sharp_ppf : string option;
  caml_ppf : string option;
  highlight : highlight option;
  mime_vals : mime_val list;
}
[@@deriving rpcty]
(** Represents the result of executing a toplevel phrase *)

type script_parts = (int * int) list (* Input length and output length *)
[@@deriving rpcty]

type exec_toplevel_result = {
  script : string;
  parts : script_parts;
  mime_vals : mime_val list;
}
[@@deriving rpcty]
(** Represents the result of executing a toplevel script *)

type cma = {
  url : string;  (** URL where the cma is available *)
  fn : string;  (** Name of the 'wrapping' function *)
}
[@@deriving rpcty]

type init_config = {
  findlib_index : string; (** URL to the findlib index file *)
  findlib_requires : string list; (** Findlib packages to require *)
  stdlib_dcs : string; (** URL to the dynamic cmis for the OCaml standard library *)
  execute : bool (** Whether this session should support execution or not. *)
} [@@deriving rpcty]
type err = InternalError of string [@@deriving rpcty]

type opt_id = string option [@@deriving rpcty]

type dependencies = string list [@@deriving rpcty]
(** The ids of the cells that are dependencies *)

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
  let id_p = Param.mk opt_id
  let dependencies_p = Param.mk dependencies
  let typecheck_result_p = Param.mk exec_result
  let exec_result_p = Param.mk exec_result

  let source_p = Param.mk source
  let position_p = Param.mk msource_position

  let completions_p = Param.mk completions
  let error_list_p = Param.mk error_list
  let typed_enclosings_p = Param.mk typed_enclosings_list
  let is_toplevel_p = Param.mk ~name:"is_toplevel" Types.bool

  let toplevel_script_p = Param.mk ~description:[
    "A toplevel script is a sequence of toplevel phrases interspersed with";
    "The output from the toplevel. Each phase must be preceded by '# ', and";
    "the output from the toplevel is indented by 2 spaces."
  ] Types.string

  let exec_toplevel_result_p = Param.mk exec_toplevel_result

  let init_libs =
    Param.mk ~name:"init_libs"
      ~description:
        [
          "Configuration for the toplevel.";
        ]
      init_config

  let init =
    declare "init"
      [ "Initialise the toplevel. This must be called before any other API." ]
      (init_libs @-> returning unit_p err)

  let setup =
    declare "setup"
      [
        "Start the toplevel. Return value is the initial blurb ";
        "printed when starting a toplevel. Note that the toplevel";
        "must be initialised first.";
      ]
      (unit_p @-> returning exec_result_p err)

  let typecheck =
    declare "typecheck"
      [ "Typecheck a phrase without actually executing it." ]
      (phrase_p @-> returning typecheck_result_p err)

  let exec =
    declare "exec"
      [
        "Execute a phrase using the toplevel. The toplevel must have been";
        "Initialised first.";
      ]
      (phrase_p @-> returning exec_result_p err)

  let exec_toplevel =
    declare "exec_toplevel"
      [
        "Execute a toplevel script. The toplevel must have been";
        "Initialised first. Returns the updated toplevel script.";
      ]
      (toplevel_script_p @-> returning exec_toplevel_result_p err)

  let compile_js =
    declare "compile_js"
      [
        "Compile a phrase to javascript. The toplevel must have been";
        "Initialised first.";
      ]
      (id_p @-> phrase_p @-> returning phrase_p err)

  let complete_prefix =
    declare "complete_prefix"
      [ 
        "Complete a prefix"
      ]
      (id_p @-> dependencies_p @-> is_toplevel_p @-> source_p @-> position_p @-> returning completions_p err)
  
  let query_errors =
    declare "query_errors"
      [
        "Query the errors in the given source"
      ]
      (id_p @-> dependencies_p @-> is_toplevel_p @-> source_p @-> returning error_list_p err)

  let type_enclosing =
    declare "type_enclosing"
      [
        "Get the type of the enclosing expression"
      ]
      (id_p @-> dependencies_p @-> is_toplevel_p @-> source_p @-> position_p @-> returning typed_enclosings_p err)
end
