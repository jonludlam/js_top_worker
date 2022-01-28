[@@@ocaml.ppx.context
  {
    tool_name = "ppx_driver";
    include_dirs = [];
    load_path = [];
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
type highlight = {
  line1: int ;
  line2: int ;
  col1: int ;
  col2: int }[@@deriving rpcty][@@ocaml.doc " An area to be highlighted "]
include
  struct
    let _ = fun (_ : highlight) -> ()
    let rec (highlight_line1 : (_, highlight) Rpc.Types.field) =
      {
        Rpc.Types.fname = "line1";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.line1);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with line1 = v })
      }
    and (highlight_line2 : (_, highlight) Rpc.Types.field) =
      {
        Rpc.Types.fname = "line2";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.line2);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with line2 = v })
      }
    and (highlight_col1 : (_, highlight) Rpc.Types.field) =
      {
        Rpc.Types.fname = "col1";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.col1);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with col1 = v })
      }
    and (highlight_col2 : (_, highlight) Rpc.Types.field) =
      {
        Rpc.Types.fname = "col2";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.col2);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with col2 = v })
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
type exec_result =
  {
  stdout: string option ;
  stderr: string option ;
  sharp_ppf: string option ;
  caml_ppf: string option ;
  highlight: highlight option }[@@deriving rpcty][@@ocaml.doc
                                                   " Represents the result of executing a toplevel phrase "]
include
  struct
    let _ = fun (_ : exec_result) -> ()
    let rec (exec_result_stdout : (_, exec_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "stdout";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.stdout);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with stdout = v })
      }
    and (exec_result_stderr : (_, exec_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "stderr";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.stderr);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with stderr = v })
      }
    and (exec_result_sharp_ppf : (_, exec_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "sharp_ppf";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.sharp_ppf);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with sharp_ppf = v })
      }
    and (exec_result_caml_ppf : (_, exec_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "caml_ppf";
        Rpc.Types.field =
          (Rpc.Types.Option (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.caml_ppf);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with caml_ppf = v })
      }
    and (exec_result_highlight : (_, exec_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "highlight";
        Rpc.Types.field = (Rpc.Types.Option typ_of_highlight);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.highlight);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with highlight = v })
      }
    and typ_of_exec_result =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField exec_result_stdout;
             Rpc.Types.BoxedField exec_result_stderr;
             Rpc.Types.BoxedField exec_result_sharp_ppf;
             Rpc.Types.BoxedField exec_result_caml_ppf;
             Rpc.Types.BoxedField exec_result_highlight];
           Rpc.Types.sname = "exec_result";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
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
                                       (let open Rpc.Types in Basic String)))
                                   >>=
                                   (fun exec_result_stderr ->
                                      (getter.Rpc.Types.field_get "stdout"
                                         (Rpc.Types.Option
                                            (let open Rpc.Types in
                                               Basic String)))
                                        >>=
                                        (fun exec_result_stdout ->
                                           return
                                             {
                                               stdout = exec_result_stdout;
                                               stderr = exec_result_stderr;
                                               sharp_ppf =
                                                 exec_result_sharp_ppf;
                                               caml_ppf =
                                                 exec_result_caml_ppf;
                                               highlight =
                                                 exec_result_highlight
                                             }))))))
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
    and _ = typ_of_exec_result
    and _ = exec_result
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type completion_result =
  {
  n: int
    [@ocaml.doc
      " The position in the input string from where the completions may be\n          inserted "];
  completions: string list [@ocaml.doc " The list of possible completions "]}
[@@deriving rpcty][@@ocaml.doc " The result returned by a 'complete' call. "]
include
  struct
    let _ = fun (_ : completion_result) -> ()
    let rec (completion_result_n : (_, completion_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "n";
        Rpc.Types.field = (let open Rpc.Types in Basic Int);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription =
          ["The position in the input string from where the completions may be";
          "inserted"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.n);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with n = v })
      }
    and (completion_result_completions :
      (_, completion_result) Rpc.Types.field) =
      {
        Rpc.Types.fname = "completions";
        Rpc.Types.field =
          (Rpc.Types.List (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["The list of possible completions"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.completions);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with completions = v })
      }
    and typ_of_completion_result =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField completion_result_n;
             Rpc.Types.BoxedField completion_result_completions];
           Rpc.Types.sname = "completion_result";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "completions"
                     (Rpc.Types.List (let open Rpc.Types in Basic String)))
                    >>=
                    (fun completion_result_completions ->
                       (getter.Rpc.Types.field_get "n"
                          (let open Rpc.Types in Basic Int))
                         >>=
                         (fun completion_result_n ->
                            return
                              {
                                n = completion_result_n;
                                completions = completion_result_completions
                              })))
         } : completion_result Rpc.Types.structure)
    and completion_result =
      {
        Rpc.Types.name = "completion_result";
        Rpc.Types.description = ["The result returned by a 'complete' call."];
        Rpc.Types.ty = typ_of_completion_result
      }
    let _ = completion_result_n
    and _ = completion_result_completions
    and _ = typ_of_completion_result
    and _ = completion_result
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type cma =
  {
  url: string [@ocaml.doc " URL where the cma is available "];
  fn: string [@ocaml.doc " Name of the 'wrapping' function "]}[@@deriving
                                                                rpcty]
include
  struct
    let _ = fun (_ : cma) -> ()
    let rec (cma_url : (_, cma) Rpc.Types.field) =
      {
        Rpc.Types.fname = "url";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["URL where the cma is available"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.url);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with url = v })
      }
    and (cma_fn : (_, cma) Rpc.Types.field) =
      {
        Rpc.Types.fname = "fn";
        Rpc.Types.field = (let open Rpc.Types in Basic String);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = ["Name of the 'wrapping' function"];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.fn);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with fn = v })
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
type init_libs = {
  cmi_urls: string list ;
  cmas: cma list }[@@deriving rpcty]
include
  struct
    let _ = fun (_ : init_libs) -> ()
    let rec (init_libs_cmi_urls : (_, init_libs) Rpc.Types.field) =
      {
        Rpc.Types.fname = "cmi_urls";
        Rpc.Types.field =
          (Rpc.Types.List (let open Rpc.Types in Basic String));
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.cmi_urls);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with cmi_urls = v })
      }
    and (init_libs_cmas : (_, init_libs) Rpc.Types.field) =
      {
        Rpc.Types.fname = "cmas";
        Rpc.Types.field = (Rpc.Types.List typ_of_cma);
        Rpc.Types.fdefault = None;
        Rpc.Types.fdescription = [];
        Rpc.Types.fversion = None;
        Rpc.Types.fget = (fun _r -> _r.cmas);
        Rpc.Types.fset = (fun v -> fun _s -> { _s with cmas = v })
      }
    and typ_of_init_libs =
      Rpc.Types.Struct
        ({
           Rpc.Types.fields =
             [Rpc.Types.BoxedField init_libs_cmi_urls;
             Rpc.Types.BoxedField init_libs_cmas];
           Rpc.Types.sname = "init_libs";
           Rpc.Types.version = None;
           Rpc.Types.constructor =
             (fun getter ->
                let open Rresult.R in
                  (getter.Rpc.Types.field_get "cmas"
                     (Rpc.Types.List typ_of_cma))
                    >>=
                    (fun init_libs_cmas ->
                       (getter.Rpc.Types.field_get "cmi_urls"
                          (Rpc.Types.List
                             (let open Rpc.Types in Basic String)))
                         >>=
                         (fun init_libs_cmi_urls ->
                            return
                              {
                                cmi_urls = init_libs_cmi_urls;
                                cmas = init_libs_cmas
                              })))
         } : init_libs Rpc.Types.structure)
    and init_libs =
      {
        Rpc.Types.name = "init_libs";
        Rpc.Types.description = [];
        Rpc.Types.ty = typ_of_init_libs
      }
    let _ = init_libs_cmi_urls
    and _ = init_libs_cmas
    and _ = typ_of_init_libs
    and _ = init_libs
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
             (fun s' ->
                fun t ->
                  let s = String.lowercase_ascii s' in
                  match s with
                  | "internalerror" ->
                      Rresult.R.bind
                        (t.tget (let open Rpc.Types in Basic String))
                        (function | a0 -> Rresult.R.ok (InternalError a0))
                  | _ ->
                      Rresult.R.error_msg
                        (Printf.sprintf "Unknown tag '%s'" s))
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
    let typecheck_result_p = Param.mk exec_result
    let exec_result_p = Param.mk exec_result
    let completion_p = Param.mk completion_result
    let init_libs =
      Param.mk ~name:"init_libs"
        ~description:["Libraries to load during the initialisation of the toplevel. ";
                     "If the stdlib cmis have not been compiled into the worker this ";
                     "MUST include the urls from which they may be fetched"]
        init_libs
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
    let complete =
      declare "complete"
        ["Find completions of the incomplete phrase. Completion occurs at the";
        "end of the phrase passed in. If completion is required at a point";
        "other than the end of a string, then take the substring before calling";
        "this API."] (phrase_p @-> (returning completion_p err))
  end
