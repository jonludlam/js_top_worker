[@@@ocaml.ppx.context
  {
    tool_name = "ppx_driver";
    include_dirs = [];
    hidden_include_dirs = [];
    load_path = ([], []);
    open_modules = [];
    for_package = None;
    debug = false;
    use_threads = false;
    use_vmthreads = false;
    recursive_types = false;
    principal = false;
    transparent_modules = false;
    unboxed_types = false;
    unsafe_string = false;
    cookies = [("library-name", "js_top_worker_rpc_def")]
  }]
[@@@ocaml.text " IDL for talking to the toplevel webworker "]
open Rpc
open Idl
let sockpath = "/tmp/js_top_worker.sock"
open Merlin_kernel
module Location = Ocaml_parsing.Location
type lexing_position = Lexing.position =
  {
  pos_fname: string ;
  pos_lnum: int ;
  pos_bol: int ;
  pos_cnum: int }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : lexing_position) -> ()
    let rec lexing_position_pos_fname : (_, lexing_position) Rpc.Types.field
      =
      {
        Rpc.Types.fname = "pos_fname";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.pos_fname);
        Rpc.Types.fset = (fun v _s -> { _s with pos_fname = v })
      }
    and lexing_position_pos_lnum : (_, lexing_position) Rpc.Types.field =
      {
        Rpc.Types.fname = "pos_lnum";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.pos_lnum);
        Rpc.Types.fset = (fun v _s -> { _s with pos_lnum = v })
      }
    and lexing_position_pos_bol : (_, lexing_position) Rpc.Types.field =
      {
        Rpc.Types.fname = "pos_bol";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.pos_bol);
        Rpc.Types.fset = (fun v _s -> { _s with pos_bol = v })
      }
    and lexing_position_pos_cnum : (_, lexing_position) Rpc.Types.field =
      {
        Rpc.Types.fname = "pos_cnum";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.pos_cnum);
        Rpc.Types.fset = (fun v _s -> { _s with pos_cnum = v })
      }
    and typ_of_lexing_position =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField lexing_position_pos_fname;
             Rpc.Types.BoxedField lexing_position_pos_lnum;
             Rpc.Types.BoxedField lexing_position_pos_bol;
             Rpc.Types.BoxedField lexing_position_pos_cnum];
           Rpc.Types.sname = "lexing_position";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "pos_cnum"
                     (let open Rpc.Types in Basic Int))
                    >>=
                    (fun lexing_position_pos_cnum ->
                       (getter.Rpc.Types.field_get "pos_bol"
                          (let open Rpc.Types in Basic Int))
                         >>=
                         (fun lexing_position_pos_bol ->
                            (getter.Rpc.Types.field_get "pos_lnum"
                               (let open Rpc.Types in Basic Int))
                              >>=
                              (fun lexing_position_pos_lnum ->
                                 (getter.Rpc.Types.field_get "pos_fname"
                                    (let open Rpc.Types in Basic String))
                                   >>=
                                   (fun lexing_position_pos_fname ->
                                      return
                                        {
                                          pos_fname =
                                            lexing_position_pos_fname;
                                          pos_lnum = lexing_position_pos_lnum;
                                          pos_bol = lexing_position_pos_bol;
                                          pos_cnum = lexing_position_pos_cnum
                                        })))))
         } : lexing_position Rpc.Types.structure)
    and lexing_position =
      {
        Rpc.Types.name = "lexing_position";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_lexing_position
      }
    let _ = lexing_position_pos_fname
    and _ = lexing_position_pos_lnum
    and _ = lexing_position_pos_bol
    and _ = lexing_position_pos_cnum
    and _ = typ_of_lexing_position
    and _ = lexing_position
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type location = Location.t =
  {
  loc_start: lexing_position ;
  loc_end: lexing_position ;
  loc_ghost: bool }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : location) -> ()
    let rec location_loc_start : (_, location) Rpc.Types.field =
      {
        Rpc.Types.fname = "loc_start";
        Rpc.Types.field = typ_of_lexing_position;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.loc_start);
        Rpc.Types.fset = (fun v _s -> { _s with loc_start = v })
      }
    and location_loc_end : (_, location) Rpc.Types.field =
      {
        Rpc.Types.fname = "loc_end";
        Rpc.Types.field = typ_of_lexing_position;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.loc_end);
        Rpc.Types.fset = (fun v _s -> { _s with loc_end = v })
      }
    and location_loc_ghost : (_, location) Rpc.Types.field =
      {
        Rpc.Types.fname = "loc_ghost";
        Rpc.Types.field = (let open Rpc.Types in Basic Bool);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.loc_ghost);
        Rpc.Types.fset = (fun v _s -> { _s with loc_ghost = v })
      }
    and typ_of_location =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField location_loc_start;
             Rpc.Types.BoxedField location_loc_end;
             Rpc.Types.BoxedField location_loc_ghost];
           Rpc.Types.sname = "location";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "loc_ghost"
                     (let open Rpc.Types in Basic Bool))
                    >>=
                    (fun location_loc_ghost ->
                       (getter.Rpc.Types.field_get "loc_end"
                          typ_of_lexing_position)
                         >>=
                         (fun location_loc_end ->
                            (getter.Rpc.Types.field_get "loc_start"
                               typ_of_lexing_position)
                              >>=
                              (fun location_loc_start ->
                                 return
                                   {
                                     loc_start = location_loc_start;
                                     loc_end = location_loc_end;
                                     loc_ghost = location_loc_ghost
                                   }))))
         } : location Rpc.Types.structure)
    and location =
      {
        Rpc.Types.name = "location";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_location
      }
    let _ = location_loc_start
    and _ = location_loc_end
    and _ = location_loc_ghost
    and _ = typ_of_location
    and _ = location
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type location_error_source = Location.error_source =
  | Lexer 
  | Parser 
  | Typer 
  | Warning 
  | Unknown 
  | Env 
  | Config [@@deriving rpcty]
include
  struct
    let _ = fun (_ : location_error_source) -> ()
    let rec typ_of_location_error_source =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "location_error_source";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "Lexer";
                  Rpc.Types.tcontents = Unit;
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | Lexer -> Some () | _ -> None));
                  Rpc.Types.treview = ((function | () -> Lexer))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "Parser";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Parser -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Parser))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Typer";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Typer -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Typer))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Warning";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Warning -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Warning))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Unknown";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Unknown -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Unknown))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Env";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Env -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Env))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Config";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Config -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Config))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "lexer" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Lexer)
                | "parser" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Parser)
                | "typer" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Typer)
                | "warning" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Warning)
                | "unknown" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Unknown)
                | "env" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Env)
                | "config" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Config)
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : location_error_source Rpc.Types.variant)
    and location_error_source =
      {
        Rpc.Types.name = "location_error_source";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_location_error_source
      }
    let _ = typ_of_location_error_source
    and _ = location_error_source
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type location_report_kind = Location.report_kind =
  | Report_error 
  | Report_warning of string 
  | Report_warning_as_error of string 
  | Report_alert of string 
  | Report_alert_as_error of string [@@deriving rpcty]
include
  struct
    let _ = fun (_ : location_report_kind) -> ()
    let rec typ_of_location_report_kind =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "location_report_kind";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "Report_error";
                  Rpc.Types.tcontents = Unit;
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | Report_error -> Some () | _ -> None));
                  Rpc.Types.treview = ((function | () -> Report_error))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "Report_warning";
                 Rpc.Types.tcontents = ((let open Rpc.Types in Basic String));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Report_warning a0 -> Some a0 | _ -> None));
                 Rpc.Types.treview = ((function | a0 -> Report_warning a0))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Report_warning_as_error";
                 Rpc.Types.tcontents = ((let open Rpc.Types in Basic String));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function
                     | Report_warning_as_error a0 -> Some a0
                     | _ -> None));
                 Rpc.Types.treview =
                   ((function | a0 -> Report_warning_as_error a0))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Report_alert";
                 Rpc.Types.tcontents = ((let open Rpc.Types in Basic String));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Report_alert a0 -> Some a0 | _ -> None));
                 Rpc.Types.treview = ((function | a0 -> Report_alert a0))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Report_alert_as_error";
                 Rpc.Types.tcontents = ((let open Rpc.Types in Basic String));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function
                     | Report_alert_as_error a0 -> Some a0
                     | _ -> None));
                 Rpc.Types.treview =
                   ((function | a0 -> Report_alert_as_error a0))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "report_error" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Report_error)
                | "report_warning" ->
                    Rresult.R.bind
                      (t.tget (let open Rpc.Types in Basic String))
                      (function | a0 -> Rresult.R.ok (Report_warning a0))
                | "report_warning_as_error" ->
                    Rresult.R.bind
                      (t.tget (let open Rpc.Types in Basic String))
                      (function
                       | a0 -> Rresult.R.ok (Report_warning_as_error a0))
                | "report_alert" ->
                    Rresult.R.bind
                      (t.tget (let open Rpc.Types in Basic String))
                      (function | a0 -> Rresult.R.ok (Report_alert a0))
                | "report_alert_as_error" ->
                    Rresult.R.bind
                      (t.tget (let open Rpc.Types in Basic String))
                      (function
                       | a0 -> Rresult.R.ok (Report_alert_as_error a0))
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : location_report_kind Rpc.Types.variant)
    and location_report_kind =
      {
        Rpc.Types.name = "location_report_kind";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_location_report_kind
      }
    let _ = typ_of_location_report_kind
    and _ = location_report_kind
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type source = string[@@deriving rpcty]
include
  struct
    let _ = fun (_ : source) -> ()
    let rec typ_of_source = let open Rpc.Types in Basic String
    and source =
      {
        Rpc.Types.name = "source";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_source
      }
    let _ = typ_of_source
    and _ = source
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
[@@@ocaml.text
  " CMIs are provided either statically or as URLs to be downloaded on demand "]
[@@@ocaml.text
  " Dynamic cmis are loaded from beneath the given url. In addition the\n    top-level modules are specified, and prefixes for other modules. For\n    example, for the OCaml standard library, a user might pass:\n\n    {[\n      { dcs_url=\"/static/stdlib\";\n        dcs_toplevel_modules=[\"Stdlib\"];\n        dcs_file_prefixes=[\"stdlib__\"]; }\n    ]}\n\n    In which case, merlin will expect to be able to download a valid file\n    from the url [\"/static/stdlib/stdlib.cmi\"] corresponding to the\n    specified toplevel module, and it will also attempt to download any\n    module with the prefix [\"Stdlib__\"] from the same base url, so for\n    example if an attempt is made to look up the module [\"Stdlib__Foo\"]\n    then merlin-js will attempt to download a file from the url\n    [\"/static/stdlib/stdlib__Foo.cmi\"].\n    "]
type dynamic_cmis =
  {
  dcs_url: string ;
  dcs_toplevel_modules: string list ;
  dcs_file_prefixes: string list }
and static_cmi = {
  sc_name: string ;
  sc_content: string }
and cmis = {
  static_cmis: static_cmi list ;
  dynamic_cmis: dynamic_cmis list }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : dynamic_cmis) -> ()
    let _ = fun (_ : static_cmi) -> ()
    let _ = fun (_ : cmis) -> ()
    let rec dynamic_cmis_dcs_url : (_, dynamic_cmis) Rpc.Types.field =
      {
        Rpc.Types.fname = "dcs_url";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.dcs_url);
        Rpc.Types.fset = (fun v _s -> { _s with dcs_url = v })
      }
    and dynamic_cmis_dcs_toplevel_modules : (_, dynamic_cmis) Rpc.Types.field
      =
      {
        Rpc.Types.fname = "dcs_toplevel_modules";
        Rpc.Types.field =
          (Rpc.Types.List (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.dcs_toplevel_modules);
        Rpc.Types.fset = (fun v _s -> { _s with dcs_toplevel_modules = v })
      }
    and dynamic_cmis_dcs_file_prefixes : (_, dynamic_cmis) Rpc.Types.field =
      {
        Rpc.Types.fname = "dcs_file_prefixes";
        Rpc.Types.field =
          (Rpc.Types.List (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.dcs_file_prefixes);
        Rpc.Types.fset = (fun v _s -> { _s with dcs_file_prefixes = v })
      }
    and typ_of_dynamic_cmis =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField dynamic_cmis_dcs_url;
             Rpc.Types.BoxedField dynamic_cmis_dcs_toplevel_modules;
             Rpc.Types.BoxedField dynamic_cmis_dcs_file_prefixes];
           Rpc.Types.sname = "dynamic_cmis";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "dcs_file_prefixes"
                     (Rpc.Types.List (let open Rpc.Types in Basic String)))
                    >>=
                    (fun dynamic_cmis_dcs_file_prefixes ->
                       (getter.Rpc.Types.field_get "dcs_toplevel_modules"
                          (Rpc.Types.List
                             (let open Rpc.Types in Basic String)))
                         >>=
                         (fun dynamic_cmis_dcs_toplevel_modules ->
                            (getter.Rpc.Types.field_get "dcs_url"
                               (let open Rpc.Types in Basic String))
                              >>=
                              (fun dynamic_cmis_dcs_url ->
                                 return
                                   {
                                     dcs_url = dynamic_cmis_dcs_url;
                                     dcs_toplevel_modules =
                                       dynamic_cmis_dcs_toplevel_modules;
                                     dcs_file_prefixes =
                                       dynamic_cmis_dcs_file_prefixes
                                   }))))
         } : dynamic_cmis Rpc.Types.structure)
    and dynamic_cmis =
      {
        Rpc.Types.name = "dynamic_cmis";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_dynamic_cmis
      }
    and static_cmi_sc_name : (_, static_cmi) Rpc.Types.field =
      {
        Rpc.Types.fname = "sc_name";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.sc_name);
        Rpc.Types.fset = (fun v _s -> { _s with sc_name = v })
      }
    and static_cmi_sc_content : (_, static_cmi) Rpc.Types.field =
      {
        Rpc.Types.fname = "sc_content";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.sc_content);
        Rpc.Types.fset = (fun v _s -> { _s with sc_content = v })
      }
    and typ_of_static_cmi =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField static_cmi_sc_name;
             Rpc.Types.BoxedField static_cmi_sc_content];
           Rpc.Types.sname = "static_cmi";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "sc_content"
                     (let open Rpc.Types in Basic String))
                    >>=
                    (fun static_cmi_sc_content ->
                       (getter.Rpc.Types.field_get "sc_name"
                          (let open Rpc.Types in Basic String))
                         >>=
                         (fun static_cmi_sc_name ->
                            return
                              {
                                sc_name = static_cmi_sc_name;
                                sc_content = static_cmi_sc_content
                              })))
         } : static_cmi Rpc.Types.structure)
    and static_cmi =
      {
        Rpc.Types.name = "static_cmi";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_static_cmi
      }
    and cmis_static_cmis : (_, cmis) Rpc.Types.field =
      {
        Rpc.Types.fname = "static_cmis";
        Rpc.Types.field = (Rpc.Types.List typ_of_static_cmi);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.static_cmis);
        Rpc.Types.fset = (fun v _s -> { _s with static_cmis = v })
      }
    and cmis_dynamic_cmis : (_, cmis) Rpc.Types.field =
      {
        Rpc.Types.fname = "dynamic_cmis";
        Rpc.Types.field = (Rpc.Types.List typ_of_dynamic_cmis);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.dynamic_cmis);
        Rpc.Types.fset = (fun v _s -> { _s with dynamic_cmis = v })
      }
    and typ_of_cmis =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField cmis_static_cmis;
             Rpc.Types.BoxedField cmis_dynamic_cmis];
           Rpc.Types.sname = "cmis";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "dynamic_cmis"
                     (Rpc.Types.List typ_of_dynamic_cmis))
                    >>=
                    (fun cmis_dynamic_cmis ->
                       (getter.Rpc.Types.field_get "static_cmis"
                          (Rpc.Types.List typ_of_static_cmi))
                         >>=
                         (fun cmis_static_cmis ->
                            return
                              {
                                static_cmis = cmis_static_cmis;
                                dynamic_cmis = cmis_dynamic_cmis
                              })))
         } : cmis Rpc.Types.structure)
    and cmis =
      {
        Rpc.Types.name = "cmis";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_cmis
      }
    let _ = dynamic_cmis_dcs_url
    and _ = dynamic_cmis_dcs_toplevel_modules
    and _ = dynamic_cmis_dcs_file_prefixes
    and _ = typ_of_dynamic_cmis
    and _ = dynamic_cmis
    and _ = static_cmi_sc_name
    and _ = static_cmi_sc_content
    and _ = typ_of_static_cmi
    and _ = static_cmi
    and _ = cmis_static_cmis
    and _ = cmis_dynamic_cmis
    and _ = typ_of_cmis
    and _ = cmis
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type action =
  | Complete_prefix of source * Msource.position 
  | Type_enclosing of source * Msource.position 
  | All_errors of source 
  | Add_cmis of cmis 
type error =
  {
  kind: location_report_kind ;
  loc: location ;
  main: string ;
  sub: string list ;
  source: location_error_source }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : error) -> ()
    let rec error_kind : (_, error) Rpc.Types.field =
      {
        Rpc.Types.fname = "kind";
        Rpc.Types.field = typ_of_location_report_kind;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.kind);
        Rpc.Types.fset = (fun v _s -> { _s with kind = v })
      }
    and error_loc : (_, error) Rpc.Types.field =
      {
        Rpc.Types.fname = "loc";
        Rpc.Types.field = typ_of_location;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.loc);
        Rpc.Types.fset = (fun v _s -> { _s with loc = v })
      }
    and error_main : (_, error) Rpc.Types.field =
      {
        Rpc.Types.fname = "main";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.main);
        Rpc.Types.fset = (fun v _s -> { _s with main = v })
      }
    and error_sub : (_, error) Rpc.Types.field =
      {
        Rpc.Types.fname = "sub";
        Rpc.Types.field =
          (Rpc.Types.List (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.sub);
        Rpc.Types.fset = (fun v _s -> { _s with sub = v })
      }
    and error_source : (_, error) Rpc.Types.field =
      {
        Rpc.Types.fname = "source";
        Rpc.Types.field = typ_of_location_error_source;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.source);
        Rpc.Types.fset = (fun v _s -> { _s with source = v })
      }
    and typ_of_error =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField error_kind;
             Rpc.Types.BoxedField error_loc;
             Rpc.Types.BoxedField error_main;
             Rpc.Types.BoxedField error_sub;
             Rpc.Types.BoxedField error_source];
           Rpc.Types.sname = "error";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "source"
                     typ_of_location_error_source)
                    >>=
                    (fun error_source ->
                       (getter.Rpc.Types.field_get "sub"
                          (Rpc.Types.List
                             (let open Rpc.Types in Basic String)))
                         >>=
                         (fun error_sub ->
                            (getter.Rpc.Types.field_get "main"
                               (let open Rpc.Types in Basic String))
                              >>=
                              (fun error_main ->
                                 (getter.Rpc.Types.field_get "loc"
                                    typ_of_location)
                                   >>=
                                   (fun error_loc ->
                                      (getter.Rpc.Types.field_get "kind"
                                         typ_of_location_report_kind)
                                        >>=
                                        (fun error_kind ->
                                           return
                                             {
                                               kind = error_kind;
                                               loc = error_loc;
                                               main = error_main;
                                               sub = error_sub;
                                               source = error_source
                                             }))))))
         } : error Rpc.Types.structure)
    and error =
      {
        Rpc.Types.name = "error";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_error
      }
    let _ = error_kind
    and _ = error_loc
    and _ = error_main
    and _ = error_sub
    and _ = error_source
    and _ = typ_of_error
    and _ = error
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type error_list = error list[@@deriving rpcty]
include
  struct
    let _ = fun (_ : error_list) -> ()
    let rec typ_of_error_list = Rpc.Types.List typ_of_error
    and error_list =
      {
        Rpc.Types.name = "error_list";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_error_list
      }
    let _ = typ_of_error_list
    and _ = error_list
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type kind_ty =
  | Constructor 
  | Keyword 
  | Label 
  | MethodCall 
  | Modtype 
  | Module 
  | Type 
  | Value 
  | Variant [@@deriving rpcty]
include
  struct
    let _ = fun (_ : kind_ty) -> ()
    let rec typ_of_kind_ty =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "kind_ty";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "Constructor";
                  Rpc.Types.tcontents = Unit;
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | Constructor -> Some () | _ -> None));
                  Rpc.Types.treview = ((function | () -> Constructor))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "Keyword";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Keyword -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Keyword))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Label";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Label -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Label))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "MethodCall";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | MethodCall -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> MethodCall))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Modtype";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Modtype -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Modtype))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Module";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Module -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Module))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Type";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Type -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Type))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Value";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Value -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Value))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Variant";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Variant -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Variant))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "constructor" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Constructor)
                | "keyword" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Keyword)
                | "label" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Label)
                | "methodcall" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok MethodCall)
                | "modtype" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Modtype)
                | "module" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Module)
                | "type" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Type)
                | "value" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Value)
                | "variant" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Variant)
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : kind_ty Rpc.Types.variant)
    and kind_ty =
      {
        Rpc.Types.name = "kind_ty";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_kind_ty
      }
    let _ = typ_of_kind_ty
    and _ = kind_ty
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type query_protocol_compl_entry =
  {
  name: string ;
  kind: kind_ty ;
  desc: string ;
  info: string ;
  deprecated: bool }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : query_protocol_compl_entry) -> ()
    let rec query_protocol_compl_entry_name :
      (_, query_protocol_compl_entry) Rpc.Types.field =
      {
        Rpc.Types.fname = "name";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.name);
        Rpc.Types.fset = (fun v _s -> { _s with name = v })
      }
    and query_protocol_compl_entry_kind :
      (_, query_protocol_compl_entry) Rpc.Types.field =
      {
        Rpc.Types.fname = "kind";
        Rpc.Types.field = typ_of_kind_ty;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.kind);
        Rpc.Types.fset = (fun v _s -> { _s with kind = v })
      }
    and query_protocol_compl_entry_desc :
      (_, query_protocol_compl_entry) Rpc.Types.field =
      {
        Rpc.Types.fname = "desc";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.desc);
        Rpc.Types.fset = (fun v _s -> { _s with desc = v })
      }
    and query_protocol_compl_entry_info :
      (_, query_protocol_compl_entry) Rpc.Types.field =
      {
        Rpc.Types.fname = "info";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.info);
        Rpc.Types.fset = (fun v _s -> { _s with info = v })
      }
    and query_protocol_compl_entry_deprecated :
      (_, query_protocol_compl_entry) Rpc.Types.field =
      {
        Rpc.Types.fname = "deprecated";
        Rpc.Types.field = (let open Rpc.Types in Basic Bool);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.deprecated);
        Rpc.Types.fset = (fun v _s -> { _s with deprecated = v })
      }
    and typ_of_query_protocol_compl_entry =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField query_protocol_compl_entry_name;
             Rpc.Types.BoxedField query_protocol_compl_entry_kind;
             Rpc.Types.BoxedField query_protocol_compl_entry_desc;
             Rpc.Types.BoxedField query_protocol_compl_entry_info;
             Rpc.Types.BoxedField query_protocol_compl_entry_deprecated];
           Rpc.Types.sname = "query_protocol_compl_entry";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "deprecated"
                     (let open Rpc.Types in Basic Bool))
                    >>=
                    (fun query_protocol_compl_entry_deprecated ->
                       (getter.Rpc.Types.field_get "info"
                          (let open Rpc.Types in Basic String))
                         >>=
                         (fun query_protocol_compl_entry_info ->
                            (getter.Rpc.Types.field_get "desc"
                               (let open Rpc.Types in Basic String))
                              >>=
                              (fun query_protocol_compl_entry_desc ->
                                 (getter.Rpc.Types.field_get "kind"
                                    typ_of_kind_ty)
                                   >>=
                                   (fun query_protocol_compl_entry_kind ->
                                      (getter.Rpc.Types.field_get "name"
                                         (let open Rpc.Types in Basic String))
                                        >>=
                                        (fun query_protocol_compl_entry_name
                                           ->
                                           return
                                             {
                                               name =
                                                 query_protocol_compl_entry_name;
                                               kind =
                                                 query_protocol_compl_entry_kind;
                                               desc =
                                                 query_protocol_compl_entry_desc;
                                               info =
                                                 query_protocol_compl_entry_info;
                                               deprecated =
                                                 query_protocol_compl_entry_deprecated
                                             }))))))
         } : query_protocol_compl_entry Rpc.Types.structure)
    and query_protocol_compl_entry =
      {
        Rpc.Types.name = "query_protocol_compl_entry";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_query_protocol_compl_entry
      }
    let _ = query_protocol_compl_entry_name
    and _ = query_protocol_compl_entry_kind
    and _ = query_protocol_compl_entry_desc
    and _ = query_protocol_compl_entry_info
    and _ = query_protocol_compl_entry_deprecated
    and _ = typ_of_query_protocol_compl_entry
    and _ = query_protocol_compl_entry
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type completions =
  {
  from: int ;
  to_: int ;
  entries: query_protocol_compl_entry list }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : completions) -> ()
    let rec completions_from : (_, completions) Rpc.Types.field =
      {
        Rpc.Types.fname = "from";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.from);
        Rpc.Types.fset = (fun v _s -> { _s with from = v })
      }
    and completions_to_ : (_, completions) Rpc.Types.field =
      {
        Rpc.Types.fname = "to_";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.to_);
        Rpc.Types.fset = (fun v _s -> { _s with to_ = v })
      }
    and completions_entries : (_, completions) Rpc.Types.field =
      {
        Rpc.Types.fname = "entries";
        Rpc.Types.field = (Rpc.Types.List typ_of_query_protocol_compl_entry);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.entries);
        Rpc.Types.fset = (fun v _s -> { _s with entries = v })
      }
    and typ_of_completions =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField completions_from;
             Rpc.Types.BoxedField completions_to_;
             Rpc.Types.BoxedField completions_entries];
           Rpc.Types.sname = "completions";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "entries"
                     (Rpc.Types.List typ_of_query_protocol_compl_entry))
                    >>=
                    (fun completions_entries ->
                       (getter.Rpc.Types.field_get "to_"
                          (let open Rpc.Types in Basic Int))
                         >>=
                         (fun completions_to_ ->
                            (getter.Rpc.Types.field_get "from"
                               (let open Rpc.Types in Basic Int))
                              >>=
                              (fun completions_from ->
                                 return
                                   {
                                     from = completions_from;
                                     to_ = completions_to_;
                                     entries = completions_entries
                                   }))))
         } : completions Rpc.Types.structure)
    and completions =
      {
        Rpc.Types.name = "completions";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_completions
      }
    let _ = completions_from
    and _ = completions_to_
    and _ = completions_entries
    and _ = typ_of_completions
    and _ = completions
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type msource_position =
  | Start 
  | Offset of int 
  | Logical of int * int 
  | End [@@deriving rpcty]
include
  struct
    let _ = fun (_ : msource_position) -> ()
    let rec typ_of_msource_position =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "msource_position";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "Start";
                  Rpc.Types.tcontents = Unit;
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | Start -> Some () | _ -> None));
                  Rpc.Types.treview = ((function | () -> Start))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "Offset";
                 Rpc.Types.tcontents = ((let open Rpc.Types in Basic Int));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Offset a0 -> Some a0 | _ -> None));
                 Rpc.Types.treview = ((function | a0 -> Offset a0))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Logical";
                 Rpc.Types.tcontents =
                   (Tuple
                      (((let open Rpc.Types in Basic Int)),
                        ((let open Rpc.Types in Basic Int))));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Logical (a0, a1) -> Some (a0, a1) | _ -> None));
                 Rpc.Types.treview =
                   ((function | (a0, a1) -> Logical (a0, a1)))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "End";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | End -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> End))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "start" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Start)
                | "offset" ->
                    Rresult.R.bind (t.tget (let open Rpc.Types in Basic Int))
                      (function | a0 -> Rresult.R.ok (Offset a0))
                | "logical" ->
                    Rresult.R.bind
                      (t.tget
                         (Tuple
                            ((let open Rpc.Types in Basic Int),
                              (let open Rpc.Types in Basic Int))))
                      (function | (a0, a1) -> Rresult.R.ok (Logical (a0, a1)))
                | "end" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok End)
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : msource_position Rpc.Types.variant)
    and msource_position =
      {
        Rpc.Types.name = "msource_position";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_msource_position
      }
    let _ = typ_of_msource_position
    and _ = msource_position
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type is_tail_position =
  | No 
  | Tail_position 
  | Tail_call [@@deriving rpcty]
include
  struct
    let _ = fun (_ : is_tail_position) -> ()
    let rec typ_of_is_tail_position =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "is_tail_position";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "No";
                  Rpc.Types.tcontents = Unit;
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | No -> Some () | _ -> None));
                  Rpc.Types.treview = ((function | () -> No))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "Tail_position";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Tail_position -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Tail_position))
               };
             BoxedTag
               {
                 Rpc.Types.tname = "Tail_call";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Tail_call -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Tail_call))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "no" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok No)
                | "tail_position" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Tail_position)
                | "tail_call" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Tail_call)
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : is_tail_position Rpc.Types.variant)
    and is_tail_position =
      {
        Rpc.Types.name = "is_tail_position";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_is_tail_position
      }
    let _ = typ_of_is_tail_position
    and _ = is_tail_position
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type index_or_string =
  | Index of int 
  | String of string [@@deriving rpcty]
include
  struct
    let _ = fun (_ : index_or_string) -> ()
    let rec typ_of_index_or_string =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "index_or_string";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "Index";
                  Rpc.Types.tcontents = ((let open Rpc.Types in Basic Int));
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | Index a0 -> Some a0 | _ -> None));
                  Rpc.Types.treview = ((function | a0 -> Index a0))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "String";
                 Rpc.Types.tcontents = ((let open Rpc.Types in Basic String));
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | String a0 -> Some a0 | _ -> None));
                 Rpc.Types.treview = ((function | a0 -> String a0))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "index" ->
                    Rresult.R.bind (t.tget (let open Rpc.Types in Basic Int))
                      (function | a0 -> Rresult.R.ok (Index a0))
                | "string" ->
                    Rresult.R.bind
                      (t.tget (let open Rpc.Types in Basic String))
                      (function | a0 -> Rresult.R.ok (String a0))
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : index_or_string Rpc.Types.variant)
    and index_or_string =
      {
        Rpc.Types.name = "index_or_string";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_index_or_string
      }
    let _ = typ_of_index_or_string
    and _ = index_or_string
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type typed_enclosings = (location * index_or_string * is_tail_position)
[@@deriving rpcty]
include
  struct
    let _ = fun (_ : typed_enclosings) -> ()
    let rec typ_of_typed_enclosings =
      Rpc.Types.Tuple3
        (typ_of_location, typ_of_index_or_string, typ_of_is_tail_position)
    and typed_enclosings =
      {
        Rpc.Types.name = "typed_enclosings";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_typed_enclosings
      }
    let _ = typ_of_typed_enclosings
    and _ = typed_enclosings
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type typed_enclosings_list = typed_enclosings list[@@deriving rpcty]
include
  struct
    let _ = fun (_ : typed_enclosings_list) -> ()
    let rec typ_of_typed_enclosings_list =
      Rpc.Types.List typ_of_typed_enclosings
    and typed_enclosings_list =
      {
        Rpc.Types.name = "typed_enclosings_list";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_typed_enclosings_list
      }
    let _ = typ_of_typed_enclosings_list
    and _ = typed_enclosings_list
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
let report_source_to_string =
  function
  | Location.Lexer -> "lexer"
  | Location.Parser -> "parser"
  | Location.Typer -> "typer"
  | Location.Warning -> "warning"
  | Location.Unknown -> "unknown"
  | Location.Env -> "env"
  | Location.Config -> "config"
type highlight = {
  line1: int ;
  line2: int ;
  col1: int ;
  col2: int }[@@deriving rpcty][@@ocaml.doc " An area to be highlighted "]
include
  struct
    let _ = fun (_ : highlight) -> ()
    let rec highlight_line1 : (_, highlight) Rpc.Types.field =
      {
        Rpc.Types.fname = "line1";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.line1);
        Rpc.Types.fset = (fun v _s -> { _s with line1 = v })
      }
    and highlight_line2 : (_, highlight) Rpc.Types.field =
      {
        Rpc.Types.fname = "line2";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.line2);
        Rpc.Types.fset = (fun v _s -> { _s with line2 = v })
      }
    and highlight_col1 : (_, highlight) Rpc.Types.field =
      {
        Rpc.Types.fname = "col1";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.col1);
        Rpc.Types.fset = (fun v _s -> { _s with col1 = v })
      }
    and highlight_col2 : (_, highlight) Rpc.Types.field =
      {
        Rpc.Types.fname = "col2";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.col2);
        Rpc.Types.fset = (fun v _s -> { _s with col2 = v })
      }
    and typ_of_highlight =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField highlight_line1;
             Rpc.Types.BoxedField highlight_line2;
             Rpc.Types.BoxedField highlight_col1;
             Rpc.Types.BoxedField highlight_col2];
           Rpc.Types.sname = "highlight";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "col2"
                     (let open Rpc.Types in Basic Int))
                    >>=
                    (fun highlight_col2 ->
                       (getter.Rpc.Types.field_get "col1"
                          (let open Rpc.Types in Basic Int))
                         >>=
                         (fun highlight_col1 ->
                            (getter.Rpc.Types.field_get "line2"
                               (let open Rpc.Types in Basic Int))
                              >>=
                              (fun highlight_line2 ->
                                 (getter.Rpc.Types.field_get "line1"
                                    (let open Rpc.Types in Basic Int))
                                   >>=
                                   (fun highlight_line1 ->
                                      return
                                        {
                                          line1 = highlight_line1;
                                          line2 = highlight_line2;
                                          col1 = highlight_col1;
                                          col2 = highlight_col2
                                        })))))
         } : highlight Rpc.Types.structure)
    and highlight =
      {
        Rpc.Types.name = "highlight";
        Rpc.Types.description = ["An area to be highlighted"];
        Rpc.Types.ty = typ_of_highlight
      }
    let _ = highlight_line1
    and _ = highlight_line2
    and _ = highlight_col1
    and _ = highlight_col2
    and _ = typ_of_highlight
    and _ = highlight
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type encoding = Mime_printer.encoding =
  | Noencoding 
  | Base64 [@@ocaml.doc " An area to be highlighted "][@@deriving rpcty]
include
  struct
    let _ = fun (_ : encoding) -> ()
    let rec typ_of_encoding =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "encoding";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "Noencoding";
                  Rpc.Types.tcontents = Unit;
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | Noencoding -> Some () | _ -> None));
                  Rpc.Types.treview = ((function | () -> Noencoding))
                };
             BoxedTag
               {
                 Rpc.Types.tname = "Base64";
                 Rpc.Types.tcontents = Unit;
                 Rpc.Types.tversion = None;
                 Rpc.Types.tdescription = [];
                 Rpc.Types.tpreview =
                   ((function | Base64 -> Some () | _ -> None));
                 Rpc.Types.treview = ((function | () -> Base64))
               }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "noencoding" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Noencoding)
                | "base64" ->
                    Rresult.R.bind (t.tget Unit)
                      (function | () -> Rresult.R.ok Base64)
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : encoding Rpc.Types.variant)
    and encoding =
      {
        Rpc.Types.name = "encoding";
        Rpc.Types.description = ["An area to be highlighted"];
        Rpc.Types.ty = typ_of_encoding
      }
    let _ = typ_of_encoding
    and _ = encoding
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type mime_val = Mime_printer.t =
  {
  mime_type: string ;
  encoding: encoding ;
  data: string }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : mime_val) -> ()
    let rec mime_val_mime_type : (_, mime_val) Rpc.Types.field =
      {
        Rpc.Types.fname = "mime_type";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.mime_type);
        Rpc.Types.fset = (fun v _s -> { _s with mime_type = v })
      }
    and mime_val_encoding : (_, mime_val) Rpc.Types.field =
      {
        Rpc.Types.fname = "encoding";
        Rpc.Types.field = typ_of_encoding;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.encoding);
        Rpc.Types.fset = (fun v _s -> { _s with encoding = v })
      }
    and mime_val_data : (_, mime_val) Rpc.Types.field =
      {
        Rpc.Types.fname = "data";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.data);
        Rpc.Types.fset = (fun v _s -> { _s with data = v })
      }
    and typ_of_mime_val =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField mime_val_mime_type;
             Rpc.Types.BoxedField mime_val_encoding;
             Rpc.Types.BoxedField mime_val_data];
           Rpc.Types.sname = "mime_val";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "data"
                     (let open Rpc.Types in Basic String))
                    >>=
                    (fun mime_val_data ->
                       (getter.Rpc.Types.field_get "encoding" typ_of_encoding)
                         >>=
                         (fun mime_val_encoding ->
                            (getter.Rpc.Types.field_get "mime_type"
                               (let open Rpc.Types in Basic String))
                              >>=
                              (fun mime_val_mime_type ->
                                 return
                                   {
                                     mime_type = mime_val_mime_type;
                                     encoding = mime_val_encoding;
                                     data = mime_val_data
                                   }))))
         } : mime_val Rpc.Types.structure)
    and mime_val =
      {
        Rpc.Types.name = "mime_val";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_mime_val
      }
    let _ = mime_val_mime_type
    and _ = mime_val_encoding
    and _ = mime_val_data
    and _ = typ_of_mime_val
    and _ = mime_val
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type exec_result =
  {
  stdout: string option ;
  stderr: string option ;
  sharp_ppf: string option ;
  caml_ppf: string option ;
  highlight: highlight option ;
  mime_vals: mime_val list }[@@deriving rpcty][@@ocaml.doc
                                                " Represents the result of executing a toplevel phrase "]
include
  struct
    let _ = fun (_ : exec_result) -> ()
    let rec exec_result_stdout : (_, exec_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "stdout";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.stdout);
        Rpc.Types.fset = (fun v _s -> { _s with stdout = v })
      }
    and exec_result_stderr : (_, exec_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "stderr";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.stderr);
        Rpc.Types.fset = (fun v _s -> { _s with stderr = v })
      }
    and exec_result_sharp_ppf : (_, exec_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "sharp_ppf";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.sharp_ppf);
        Rpc.Types.fset = (fun v _s -> { _s with sharp_ppf = v })
      }
    and exec_result_caml_ppf : (_, exec_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "caml_ppf";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.caml_ppf);
        Rpc.Types.fset = (fun v _s -> { _s with caml_ppf = v })
      }
    and exec_result_highlight : (_, exec_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "highlight";
        Rpc.Types.field = (Rpc.Types.Option typ_of_highlight);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.highlight);
        Rpc.Types.fset = (fun v _s -> { _s with highlight = v })
      }
    and exec_result_mime_vals : (_, exec_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "mime_vals";
        Rpc.Types.field = (Rpc.Types.List typ_of_mime_val);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.mime_vals);
        Rpc.Types.fset = (fun v _s -> { _s with mime_vals = v })
      }
    and typ_of_exec_result =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField exec_result_stdout;
             Rpc.Types.BoxedField exec_result_stderr;
             Rpc.Types.BoxedField exec_result_sharp_ppf;
             Rpc.Types.BoxedField exec_result_caml_ppf;
             Rpc.Types.BoxedField exec_result_highlight;
             Rpc.Types.BoxedField exec_result_mime_vals];
           Rpc.Types.sname = "exec_result";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "mime_vals"
                     (Rpc.Types.List typ_of_mime_val))
                    >>=
                    (fun exec_result_mime_vals ->
                       (getter.Rpc.Types.field_get "highlight"
                          (Rpc.Types.Option typ_of_highlight))
                         >>=
                         (fun exec_result_highlight ->
                            (getter.Rpc.Types.field_get "caml_ppf"
                               (Rpc.Types.Option
                                  (let open Rpc.Types in Basic String)))
                              >>=
                              (fun exec_result_caml_ppf ->
                                 (getter.Rpc.Types.field_get "sharp_ppf"
                                    (Rpc.Types.Option
                                       (let open Rpc.Types in Basic String)))
                                   >>=
                                   (fun exec_result_sharp_ppf ->
                                      (getter.Rpc.Types.field_get "stderr"
                                         (Rpc.Types.Option
                                            (let open Rpc.Types in
                                               Basic String)))
                                        >>=
                                        (fun exec_result_stderr ->
                                           (getter.Rpc.Types.field_get
                                              "stdout"
                                              (Rpc.Types.Option
                                                 (let open Rpc.Types in
                                                    Basic String)))
                                             >>=
                                             (fun exec_result_stdout ->
                                                return
                                                  {
                                                    stdout =
                                                      exec_result_stdout;
                                                    stderr =
                                                      exec_result_stderr;
                                                    sharp_ppf =
                                                      exec_result_sharp_ppf;
                                                    caml_ppf =
                                                      exec_result_caml_ppf;
                                                    highlight =
                                                      exec_result_highlight;
                                                    mime_vals =
                                                      exec_result_mime_vals
                                                  })))))))
         } : exec_result Rpc.Types.structure)
    and exec_result =
      {
        Rpc.Types.name = "exec_result";
        Rpc.Types.description =
          ["Represents the result of executing a toplevel phrase"];
        Rpc.Types.ty = typ_of_exec_result
      }
    let _ = exec_result_stdout
    and _ = exec_result_stderr
    and _ = exec_result_sharp_ppf
    and _ = exec_result_caml_ppf
    and _ = exec_result_highlight
    and _ = exec_result_mime_vals
    and _ = typ_of_exec_result
    and _ = exec_result
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type script_parts = (int * int) list[@@deriving rpcty]
include
  struct
    let _ = fun (_ : script_parts) -> ()
    let rec typ_of_script_parts =
      Rpc.Types.List
        (Rpc.Types.Tuple
           ((let open Rpc.Types in Basic Int),
             (let open Rpc.Types in Basic Int)))
    and script_parts =
      {
        Rpc.Types.name = "script_parts";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_script_parts
      }
    let _ = typ_of_script_parts
    and _ = script_parts
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type exec_toplevel_result =
  {
  script: string ;
  parts: script_parts ;
  mime_vals: mime_val list }[@@deriving rpcty][@@ocaml.doc
                                                " Represents the result of executing a toplevel script "]
include
  struct
    let _ = fun (_ : exec_toplevel_result) -> ()
    let rec exec_toplevel_result_script :
      (_, exec_toplevel_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "script";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.script);
        Rpc.Types.fset = (fun v _s -> { _s with script = v })
      }
    and exec_toplevel_result_parts :
      (_, exec_toplevel_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "parts";
        Rpc.Types.field = typ_of_script_parts;
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.parts);
        Rpc.Types.fset = (fun v _s -> { _s with parts = v })
      }
    and exec_toplevel_result_mime_vals :
      (_, exec_toplevel_result) Rpc.Types.field =
      {
        Rpc.Types.fname = "mime_vals";
        Rpc.Types.field = (Rpc.Types.List typ_of_mime_val);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.mime_vals);
        Rpc.Types.fset = (fun v _s -> { _s with mime_vals = v })
      }
    and typ_of_exec_toplevel_result =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField exec_toplevel_result_script;
             Rpc.Types.BoxedField exec_toplevel_result_parts;
             Rpc.Types.BoxedField exec_toplevel_result_mime_vals];
           Rpc.Types.sname = "exec_toplevel_result";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "mime_vals"
                     (Rpc.Types.List typ_of_mime_val))
                    >>=
                    (fun exec_toplevel_result_mime_vals ->
                       (getter.Rpc.Types.field_get "parts"
                          typ_of_script_parts)
                         >>=
                         (fun exec_toplevel_result_parts ->
                            (getter.Rpc.Types.field_get "script"
                               (let open Rpc.Types in Basic String))
                              >>=
                              (fun exec_toplevel_result_script ->
                                 return
                                   {
                                     script = exec_toplevel_result_script;
                                     parts = exec_toplevel_result_parts;
                                     mime_vals =
                                       exec_toplevel_result_mime_vals
                                   }))))
         } : exec_toplevel_result Rpc.Types.structure)
    and exec_toplevel_result =
      {
        Rpc.Types.name = "exec_toplevel_result";
        Rpc.Types.description =
          ["Represents the result of executing a toplevel script"];
        Rpc.Types.ty = typ_of_exec_toplevel_result
      }
    let _ = exec_toplevel_result_script
    and _ = exec_toplevel_result_parts
    and _ = exec_toplevel_result_mime_vals
    and _ = typ_of_exec_toplevel_result
    and _ = exec_toplevel_result
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type cma =
  {
  url: string [@ocaml.doc " URL where the cma is available "];
  fn: string [@ocaml.doc " Name of the 'wrapping' function "]}[@@deriving
                                                                rpcty]
include
  struct
    let _ = fun (_ : cma) -> ()
    let rec cma_url : (_, cma) Rpc.Types.field =
      {
        Rpc.Types.fname = "url";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["URL where the cma is available"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.url);
        Rpc.Types.fset = (fun v _s -> { _s with url = v })
      }
    and cma_fn : (_, cma) Rpc.Types.field =
      {
        Rpc.Types.fname = "fn";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["Name of the 'wrapping' function"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.fn);
        Rpc.Types.fset = (fun v _s -> { _s with fn = v })
      }
    and typ_of_cma =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField cma_url; Rpc.Types.BoxedField cma_fn];
           Rpc.Types.sname = "cma";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "fn"
                     (let open Rpc.Types in Basic String))
                    >>=
                    (fun cma_fn ->
                       (getter.Rpc.Types.field_get "url"
                          (let open Rpc.Types in Basic String))
                         >>=
                         (fun cma_url ->
                            return { url = cma_url; fn = cma_fn })))
         } : cma Rpc.Types.structure)
    and cma =
      {
        Rpc.Types.name = "cma";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_cma
      }
    let _ = cma_url
    and _ = cma_fn
    and _ = typ_of_cma
    and _ = cma
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type init_config =
  {
  findlib_index: string [@ocaml.doc " URL to the findlib index file "];
  findlib_requires: string list [@ocaml.doc " Findlib packages to require "];
  stdlib_dcs: string
    [@ocaml.doc " URL to the dynamic cmis for the OCaml standard library "];
  execute: bool
    [@ocaml.doc " Whether this session should support execution or not. "]}
[@@deriving rpcty]
include
  struct
    let _ = fun (_ : init_config) -> ()
    let rec init_config_findlib_index : (_, init_config) Rpc.Types.field =
      {
        Rpc.Types.fname = "findlib_index";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["URL to the findlib index file"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.findlib_index);
        Rpc.Types.fset = (fun v _s -> { _s with findlib_index = v })
      }
    and init_config_findlib_requires : (_, init_config) Rpc.Types.field =
      {
        Rpc.Types.fname = "findlib_requires";
        Rpc.Types.field =
          (Rpc.Types.List (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["Findlib packages to require"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.findlib_requires);
        Rpc.Types.fset = (fun v _s -> { _s with findlib_requires = v })
      }
    and init_config_stdlib_dcs : (_, init_config) Rpc.Types.field =
      {
        Rpc.Types.fname = "stdlib_dcs";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription =
          ["URL to the dynamic cmis for the OCaml standard library"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.stdlib_dcs);
        Rpc.Types.fset = (fun v _s -> { _s with stdlib_dcs = v })
      }
    and init_config_execute : (_, init_config) Rpc.Types.field =
      {
        Rpc.Types.fname = "execute";
        Rpc.Types.field = (let open Rpc.Types in Basic Bool);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription =
          ["Whether this session should support execution or not."];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.execute);
        Rpc.Types.fset = (fun v _s -> { _s with execute = v })
      }
    and typ_of_init_config =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField init_config_findlib_index;
             Rpc.Types.BoxedField init_config_findlib_requires;
             Rpc.Types.BoxedField init_config_stdlib_dcs;
             Rpc.Types.BoxedField init_config_execute];
           Rpc.Types.sname = "init_config";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "execute"
                     (let open Rpc.Types in Basic Bool))
                    >>=
                    (fun init_config_execute ->
                       (getter.Rpc.Types.field_get "stdlib_dcs"
                          (let open Rpc.Types in Basic String))
                         >>=
                         (fun init_config_stdlib_dcs ->
                            (getter.Rpc.Types.field_get "findlib_requires"
                               (Rpc.Types.List
                                  (let open Rpc.Types in Basic String)))
                              >>=
                              (fun init_config_findlib_requires ->
                                 (getter.Rpc.Types.field_get "findlib_index"
                                    (let open Rpc.Types in Basic String))
                                   >>=
                                   (fun init_config_findlib_index ->
                                      return
                                        {
                                          findlib_index =
                                            init_config_findlib_index;
                                          findlib_requires =
                                            init_config_findlib_requires;
                                          stdlib_dcs = init_config_stdlib_dcs;
                                          execute = init_config_execute
                                        })))))
         } : init_config Rpc.Types.structure)
    and init_config =
      {
        Rpc.Types.name = "init_config";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_init_config
      }
    let _ = init_config_findlib_index
    and _ = init_config_findlib_requires
    and _ = init_config_stdlib_dcs
    and _ = init_config_execute
    and _ = typ_of_init_config
    and _ = init_config
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type err =
  | InternalError of string [@@deriving rpcty]
include
  struct
    let _ = fun (_ : err) -> ()
    let rec typ_of_err =
      Rpc.Types.Variant
        ({
           Rpc.Types.vname = "err";
           Rpc.Types.variants =
             [BoxedTag
                {
                  Rpc.Types.tname = "InternalError";
                  Rpc.Types.tcontents =
                    ((let open Rpc.Types in Basic String));
                  Rpc.Types.tversion = None;
                  Rpc.Types.tdescription = [];
                  Rpc.Types.tpreview =
                    ((function | InternalError a0 -> Some a0));
                  Rpc.Types.treview = ((function | a0 -> InternalError a0))
                }];
           Rpc.Types.vdefault = None;
           Rpc.Types.vversion = None;
           Rpc.Types.vconstructor =
             (fun s' t ->
                let s = String.lowercase_ascii s' in
                match s with
                | "internalerror" ->
                    Rresult.R.bind
                      (t.tget (let open Rpc.Types in Basic String))
                      (function | a0 -> Rresult.R.ok (InternalError a0))
                | _ ->
                    Rresult.R.error_msg (Printf.sprintf "Unknown tag '%s'" s))
         } : err Rpc.Types.variant)
    and err =
      {
        Rpc.Types.name = "err";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_err
      }
    let _ = typ_of_err
    and _ = err
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type opt_id = string option[@@deriving rpcty]
include
  struct
    let _ = fun (_ : opt_id) -> ()
    let rec typ_of_opt_id =
      Rpc.Types.Option (let open Rpc.Types in Basic String)
    and opt_id =
      {
        Rpc.Types.name = "opt_id";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_opt_id
      }
    let _ = typ_of_opt_id
    and _ = opt_id
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type dependencies = string list[@@deriving rpcty][@@ocaml.doc
                                                   " The ids of the cells that are dependencies "]
include
  struct
    let _ = fun (_ : dependencies) -> ()
    let rec typ_of_dependencies =
      Rpc.Types.List (let open Rpc.Types in Basic String)
    and dependencies =
      {
        Rpc.Types.name = "dependencies";
        Rpc.Types.description =
          ["The ids of the cells that are dependencies"];
        Rpc.Types.ty = typ_of_dependencies
      }
    let _ = typ_of_dependencies
    and _ = dependencies
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
module E =
  (Idl.Error.Make)(struct
                     type t = err
                     let t = err
                     let internal_error_of e =
                       Some (InternalError (Printexc.to_string e))
                   end)
let err = E.error
module Make(R:RPC) =
  struct
    open R
    let description =
      let open Interface in
        {
          name = "Toplevel";
          namespace = None;
          description =
            ["Functions for manipulating the toplevel worker thread"];
          version = (1, 0, 0)
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
    let toplevel_script_p =
      Param.mk
        ~description:["A toplevel script is a sequence of toplevel phrases interspersed with";
                     "The output from the toplevel. Each phase must be preceded by '# ', and";
                     "the output from the toplevel is indented by 2 spaces."]
        Types.string
    let exec_toplevel_result_p = Param.mk exec_toplevel_result
    let init_libs =
      Param.mk ~name:"init_libs"
        ~description:["Configuration for the toplevel."] init_config
    let init =
      declare "init"
        ["Initialise the toplevel. This must be called before any other API."]
        (init_libs @-> (returning unit_p err))
    let setup =
      declare "setup"
        ["Start the toplevel. Return value is the initial blurb ";
        "printed when starting a toplevel. Note that the toplevel";
        "must be initialised first."]
        (unit_p @-> (returning exec_result_p err))
    let typecheck =
      declare "typecheck"
        ["Typecheck a phrase without actually executing it."]
        (phrase_p @-> (returning typecheck_result_p err))
    let exec =
      declare "exec"
        ["Execute a phrase using the toplevel. The toplevel must have been";
        "Initialised first."] (phrase_p @-> (returning exec_result_p err))
    let exec_toplevel =
      declare "exec_toplevel"
        ["Execute a toplevel script. The toplevel must have been";
        "Initialised first. Returns the updated toplevel script."]
        (toplevel_script_p @-> (returning exec_toplevel_result_p err))
    let compile_js =
      declare "compile_js"
        ["Compile a phrase to javascript. The toplevel must have been";
        "Initialised first."]
        (id_p @-> (phrase_p @-> (returning phrase_p err)))
    let complete_prefix =
      declare "complete_prefix" ["Complete a prefix"]
        (id_p @->
           (dependencies_p @->
              (is_toplevel_p @->
                 (source_p @-> (position_p @-> (returning completions_p err))))))
    let query_errors =
      declare "query_errors" ["Query the errors in the given source"]
        (id_p @->
           (dependencies_p @->
              (is_toplevel_p @-> (source_p @-> (returning error_list_p err)))))
    let type_enclosing =
      declare "type_enclosing" ["Get the type of the enclosing expression"]
        (id_p @->
           (dependencies_p @->
              (is_toplevel_p @->
                 (source_p @->
                    (position_p @-> (returning typed_enclosings_p err))))))
  end
