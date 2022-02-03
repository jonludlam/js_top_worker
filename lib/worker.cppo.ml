open Js_of_ocaml_toplevel
open Js_top_worker_rpc

let optbind : 'a option -> ('a -> 'b option) -> 'b option = fun x fn -> match x with | None -> None | Some a -> fn a 

let log fmt =
  Format.kasprintf
    (fun s -> Js_of_ocaml.(Firebug.console##log (Js.string s)))
    fmt

(* OCamlorg toplevel in a web worker

   This communicates with the toplevel code via the API defined in
   {!Toplevel_api}. This allows the OCaml execution to not block the "main
   thread" keeping the page responsive. *)

module Version = struct
  type t = int list

  let split_char ~sep p =
    let len = String.length p in
    let rec split beg cur =
      if cur >= len then
        if cur - beg > 0 then [ String.sub p beg (cur - beg) ] else []
      else if sep p.[cur] then
        String.sub p beg (cur - beg) :: split (cur + 1) (cur + 1)
      else split beg (cur + 1)
    in
    split 0 0

  let split v =
    match
      split_char ~sep:(function '+' | '-' | '~' -> true | _ -> false) v
    with
    | [] -> assert false
    | x :: _ ->
        List.map int_of_string
          (split_char ~sep:(function '.' -> true | _ -> false) x)

  let current = split Sys.ocaml_version
  let compint (a : int) b = compare a b

  let rec compare v v' =
    match (v, v') with
    | [ x ], [ y ] -> compint x y
    | [], [] -> 0
    | [], y :: _ -> compint 0 y
    | x :: _, [] -> compint x 0
    | x :: xs, y :: ys -> (
        match compint x y with 0 -> compare xs ys | n -> n)
end

let exec' s =
  let res : bool = JsooTop.use Format.std_formatter s in
  if not res then Format.eprintf "error while evaluating %s@." s

let setup functions () =
  JsooTop.initialize ();
  List.iter (fun f -> f ()) functions;
  Sys.interactive := false;
  if Version.compare Version.current [ 4; 07 ] >= 0 then exec' "open Stdlib";
  let header1 = Printf.sprintf "        %s version %%s" "OCaml" in
  let header2 =
    Printf.sprintf "     Compiled with Js_of_ocaml version %s"
      Js_of_ocaml.Sys_js.js_of_ocaml_version
  in
  exec' (Printf.sprintf "Format.printf \"%s@.\" Sys.ocaml_version;;" header1);
  exec' (Printf.sprintf "Format.printf \"%s@.\";;" header2);
  exec' "#enable \"pretty\";;";
  exec' "#disable \"shortvar\";;";
  Toploop.add_directive "load_js"
    (Toploop.Directive_string
       (fun name -> Js_of_ocaml.Js.Unsafe.global##load_script_ name))
    Toploop.{ section = ""; doc = "Load a javascript script" };
  Sys.interactive := true;
  ()

let setup_printers () =
  exec' "let _print_unit fmt (_ : 'a) : 'a = Format.pp_print_string fmt \"()\"";
  Topdirs.dir_install_printer Format.std_formatter
    Longident.(Lident "_print_unit")

let stdout_buff = Buffer.create 100
let stderr_buff = Buffer.create 100

(* RPC function implementations *)

module M = Idl.IdM (* Server is synchronous *)

module IdlM = Idl.Make (M)
module Server = Toplevel_api_gen.Make (IdlM.GenServer ())

(* These are all required to return the appropriate value for the API within the
   [IdlM.T] monad. The simplest way to do this is to use [IdlM.ErrM.return] for
   the success case and [IdlM.ErrM.return_err] for the failure case *)

let buff_opt b = match Buffer.contents b with "" -> None | s -> Some s

let execute =
  let code_buff = Buffer.create 100 in
  let res_buff = Buffer.create 100 in
  let pp_code = Format.formatter_of_buffer code_buff in
  let pp_result = Format.formatter_of_buffer res_buff in
  let highlighted = ref None in
  let highlight_location loc =
    let _file1, line1, col1 = Location.get_pos_info loc.Location.loc_start in
    let _file2, line2, col2 = Location.get_pos_info loc.Location.loc_end in
    highlighted := Some Toplevel_api_gen.{ line1; col1; line2; col2 }
  in
  fun phrase ->
    Buffer.clear code_buff;
    Buffer.clear res_buff;
    Buffer.clear stderr_buff;
    Buffer.clear stdout_buff;
    JsooTop.execute true ~pp_code ~highlight_location pp_result phrase;
    Format.pp_print_flush pp_code ();
    Format.pp_print_flush pp_result ();
    IdlM.ErrM.return
      Toplevel_api_gen.
        {
          stdout = buff_opt stdout_buff;
          stderr = buff_opt stderr_buff;
          sharp_ppf = buff_opt code_buff;
          caml_ppf = buff_opt res_buff;
          highlight = !highlighted;
        }

let sync_get url =
  let open Js_of_ocaml in
  let x = XmlHttpRequest.create () in
  x##.responseType := Js.string "arraybuffer";
  x##_open (Js.string "GET") (Js.string url) Js._false;
  x##send Js.null;
  match x##.status with
  | 200 ->
      Js.Opt.case
        (File.CoerceTo.arrayBuffer x##.response)
        (fun () ->
          Firebug.console##log (Js.string "Failed to receive file");
          None)
        (fun b -> Some (Typed_array.String.of_arrayBuffer b))
  | _ -> None

type signature = Types.signature_item list
type flags = Cmi_format.pers_flags list
type header = string * signature
type crcs = (string * Digest.t option) list 

(** The following two functions are taken from cmi_format.ml in
    the compiler, but changed to work on bytes rather than input
    channels *)
let input_cmi str =
  let offset = 0 in
  let (name, sign) = (Marshal.from_bytes str offset : header) in
  let offset = offset + Marshal.total_size str offset in
  let crcs = (Marshal.from_bytes str offset : crcs) in
  let offset = offset + Marshal.total_size str offset in
  let flags = (Marshal.from_bytes str offset : flags) in
  {
    Cmi_format.cmi_name = name;
    cmi_sign = sign;
    cmi_crcs = crcs;
    cmi_flags = flags;
  }

let read_cmi filename str =
  let magic_len = String.length Config.cmi_magic_number in
  let buffer = Bytes.sub str 0 magic_len in
  (if buffer <> Bytes.of_string Config.cmi_magic_number then
   let pre_len = String.length Config.cmi_magic_number - 3 in
   if
     Bytes.sub buffer 0 pre_len
     = Bytes.of_string @@ String.sub Config.cmi_magic_number 0 pre_len
   then
     let msg =
       if buffer < Bytes.of_string Config.cmi_magic_number then "an older"
       else "a newer"
     in
     raise (Cmi_format.Error (Wrong_version_interface (filename, msg)))
   else raise (Cmi_format.Error (Not_an_interface filename)));
  input_cmi (Bytes.sub str magic_len (Bytes.length str - magic_len))

let functions : (unit -> unit) list option ref = ref None

let init (init_libs : Toplevel_api_gen.init_libs) =
  let open Js_of_ocaml in
  try
    Clflags.no_check_prims := true;
    let cmi_files =
      List.map
        (fun cmi -> (Filename.basename cmi |> Filename.chop_extension, cmi))
        init_libs.cmi_urls
    in
#if OCAML_VERSION < (4,9,0)
    let open Env.Persistent_signature in
#else
    let open Persistent_env.Persistent_signature in
#endif
    let old_loader = !load in
    (load :=
       fun ~unit_name ->
         let result =
            optbind
             (try Some (List.assoc (String.uncapitalize_ascii unit_name) cmi_files) with _ -> None)
             sync_get
         in
         match result with
         | Some x ->
             Some
               {
                 filename =
                   Sys.executable_name;
                 cmi = read_cmi unit_name (Bytes.of_string x);
               }
         | _ -> old_loader ~unit_name);
    Js_of_ocaml.Worker.import_scripts
      (List.map (fun cma -> cma.Toplevel_api_gen.url) init_libs.cmas);
    functions :=
      Some
        (List.map
           (fun func_name ->
             Firebug.console##log (Js.string ("Function: " ^ func_name));
             let func = Js.Unsafe.js_expr func_name in
             fun () ->
               Js.Unsafe.fun_call func [| Js.Unsafe.inject Dom_html.window |])
           (List.map (fun cma -> cma.Toplevel_api_gen.fn) init_libs.cmas));
    IdlM.ErrM.return ()
  with e ->
    IdlM.ErrM.return_err (Toplevel_api_gen.InternalError (Printexc.to_string e))

let setup () =
  let open Js_of_ocaml in
  try
    Sys_js.set_channel_flusher stdout (Buffer.add_string stdout_buff);
    Sys_js.set_channel_flusher stderr (Buffer.add_string stderr_buff);
    (match !functions with
    | Some l -> setup l ()
    | None -> failwith "Error: toplevel has not been initialised");
    setup_printers ();
    IdlM.ErrM.return
      Toplevel_api_gen.
        {
          stdout = buff_opt stdout_buff;
          stderr = buff_opt stderr_buff;
          sharp_ppf = None;
          caml_ppf = None;
          highlight = None;
        }
  with e ->
    IdlM.ErrM.return_err (Toplevel_api_gen.InternalError (Printexc.to_string e))

let complete phrase =
  let contains_double_underscore s =
    let len = String.length s in
    let rec aux i =
      if i > len - 2 then false
      else if s.[i] = '_' && s.[i + 1] = '_' then true
      else aux (i + 1)
    in
    aux 0
  in
  let n, res = UTop_complete.complete ~phrase_terminator:";;" ~input:phrase in
  let res =
    List.filter (fun (l, _) -> not (contains_double_underscore l)) res
  in
  let completions = List.map fst res in
  IdlM.ErrM.return Toplevel_api_gen.{ n; completions }

let server process e =
  let call : Rpc.call = Marshal.from_bytes e 0 in
  M.bind (process call) (fun response ->
      Js_of_ocaml.Worker.post_message (Marshal.to_string response []));
  ()

  let loc = function
  | Syntaxerr.Error x ->
    Some (Syntaxerr.location_of_error x)
  | Lexer.Error (_, loc)
  | Typecore.Error (loc, _, _)
  | Typetexp.Error (loc, _, _)
  | Typeclass.Error (loc, _, _)
  | Typemod.Error (loc, _, _)
  | Typedecl.Error (loc, _)
  | Translcore.Error (loc, _)
  | Translclass.Error (loc, _)
  | Translmod.Error (loc, _) ->
    Some loc
  | _ ->
    None

let refill_lexbuf s p ppf buffer len =
  if !p = String.length s then
    0
  else
    let len', nl =
      try String.index_from s !p '\n' - !p + 1, false with
      | _ ->
        String.length s - !p, true
    in
    let len'' = min len len' in
    String.blit s !p buffer 0 len'';
    (match ppf with
    | Some ppf ->
      Format.fprintf ppf "%s" (Bytes.sub_string buffer 0 len'');
      if nl then Format.pp_print_newline ppf ();
      Format.pp_print_flush ppf ()
    | None ->
      ());
    p := !p + len'';
    len''

let typecheck_phrase =
  let res_buff = Buffer.create 100 in
  let pp_result = Format.formatter_of_buffer res_buff in
  let highlighted = ref None in
  let highlight_location loc =
    let _file1, line1, col1 = Location.get_pos_info loc.Location.loc_start in
    let _file2, line2, col2 = Location.get_pos_info loc.Location.loc_end in
    highlighted := Some Toplevel_api_gen.{ line1; col1; line2; col2 }
  in
  fun phr ->
    Buffer.clear res_buff;
    Buffer.clear stderr_buff;
    Buffer.clear stdout_buff;
    try
      let lb = Lexing.from_function (refill_lexbuf phr (ref 0) None) in
      let phr = !Toploop.parse_toplevel_phrase lb in
      let phr = Toploop.preprocess_phrase pp_result phr in
      match phr with
      | Parsetree.Ptop_def sstr ->
        let oldenv = !Toploop.toplevel_env in
        Typecore.reset_delayed_checks ();
#if OCAML_VERSION >= (4,8,0) && OCAML_VERSION < (4,14,0)
        let str, sg, sn, newenv = Typemod.type_toplevel_phrase oldenv sstr in
        let sg' = Typemod.Signature_names.simplify newenv sn sg in
        ignore (Includemod.signatures ~mark:Mark_positive oldenv sg sg');
#elif OCAML_VERSION >= (4,14,0)
        let str, sg, sn, _, newenv = Typemod.type_toplevel_phrase oldenv sstr in
        let sg' = Typemod.Signature_names.simplify newenv sn sg in
        ignore (Includemod.signatures ~mark:Mark_positive oldenv sg sg');
#else
        let str, sg, newenv = Typemod.type_toplevel_phrase oldenv sstr in
        let sg' = Typemod.simplify_signature sg in
        ignore (Includemod.signatures oldenv sg sg');
#endif
        Typecore.force_delayed_checks ();
        Printtyped.implementation pp_result str;
        Format.pp_print_flush pp_result ();
        Warnings.check_fatal ();
        flush_all ();
        IdlM.ErrM.return
          Toplevel_api_gen.
            { stdout = buff_opt stdout_buff
            ; stderr = buff_opt stderr_buff
            ; sharp_ppf = None
            ; caml_ppf = buff_opt res_buff
            ; highlight = !highlighted
            }
      | _ ->
        failwith "Typechecking"
    with
    | x ->
      (match loc x with None -> () | Some loc -> highlight_location loc);
      Errors.report_error Format.err_formatter x;
      IdlM.ErrM.return
        Toplevel_api_gen.
          { stdout = buff_opt stdout_buff
          ; stderr = buff_opt stderr_buff
          ; sharp_ppf = None
          ; caml_ppf = buff_opt res_buff
          ; highlight = !highlighted
          }

let run () =
  (* Here we bind the server stub functions to the implementations *)
  let open Js_of_ocaml in
  try
    (Js_top_worker_rpc.Idl.logfn :=
       fun s -> Js_of_ocaml.(Firebug.console##log s));
    Server.complete complete;
    Server.exec execute;
    Server.setup setup;
    Server.init init;
    Server.typecheck typecheck_phrase;
    let rpc_fn = IdlM.server Server.implementation in
    Js_of_ocaml.Worker.set_onmessage (server rpc_fn);
    Firebug.console##log (Js.string "All finished")
  with e ->
    Firebug.console##log (Js.string ("Exception: " ^ Printexc.to_string e))
