(* Implementation *)
open Js_top_worker_rpc
module M = Idl.IdM (* Server is synchronous *)
module IdlM = Idl.Make (M)

type captured = { stdout : string; stderr : string }

let modname_of_id id = "Cell__" ^ id

module JsooTopPpx = struct
  open Js_of_ocaml_compiler.Stdlib

  let ppx_rewriters = ref [ (fun _ -> Ppx_js.mapper) ]

  let () =
    Ast_mapper.register_function :=
      fun _ f -> ppx_rewriters := f :: !ppx_rewriters

  let preprocess_structure str =
    let open Ast_mapper in
    Printf.eprintf "Rewriting...\n%!";
    List.fold_right !ppx_rewriters ~init:str ~f:(fun ppx_rewriter str ->
        let mapper = ppx_rewriter [] in
        mapper.structure mapper str)

  let preprocess_signature str =
    let open Ast_mapper in
    List.fold_right !ppx_rewriters ~init:str ~f:(fun ppx_rewriter str ->
        let mapper = ppx_rewriter [] in
        mapper.signature mapper str)

  let preprocess_phrase phrase =
    let open Parsetree in
    match phrase with
    | Ptop_def str -> Ptop_def (preprocess_structure str)
    | Ptop_dir _ as x -> x
end

module type S = sig
  type findlib_t

  val capture : (unit -> 'a) -> unit -> captured * 'a
  val create_file : name:string -> content:string -> unit
  val sync_get : string -> string option
  val import_scripts : string list -> unit
  val init_function : string -> unit -> unit
  val get_stdlib_dcs : string -> Toplevel_api_gen.dynamic_cmis list
  val findlib_init : string -> findlib_t
  val require : findlib_t -> string list -> Toplevel_api_gen.dynamic_cmis list
end

module Make (S : S) = struct
  let functions : (unit -> unit) list option ref = ref None
  let requires : string list ref = ref []
  let path : string option ref = ref None
  let findlib_v : S.findlib_t option ref = ref None

  let refill_lexbuf s p ppf buffer len =
    if !p = String.length s then 0
    else
      let len', nl =
        try (String.index_from s !p '\n' - !p + 1, false)
        with _ -> (String.length s - !p, true)
      in
      let len'' = min len len' in
      String.blit s !p buffer 0 len'';
      (match ppf with
      | Some ppf ->
          Format.fprintf ppf "%s" (Bytes.sub_string buffer 0 len'');
          if nl then Format.pp_print_newline ppf ();
          Format.pp_print_flush ppf ()
      | None -> ());
      p := !p + len'';
      len''

  (* RPC function implementations *)

  (* These are all required to return the appropriate value for the API within the
     [IdlM.T] monad. The simplest way to do this is to use [IdlM.ErrM.return] for
     the success case and [IdlM.ErrM.return_err] for the failure case *)

  let exec' s =
    S.capture
      (fun () ->
        let res : bool = Toploop.use_silently Format.std_formatter (String s) in
        if not res then Format.eprintf "error while evaluating %s@." s)
      ()

  let setup functions () =
    let stdout_buff = Buffer.create 100 in
    let stderr_buff = Buffer.create 100 in

    let combine o =
      Buffer.add_string stdout_buff o.stdout;
      Buffer.add_string stderr_buff o.stderr
    in

    let exec' s =
      let o, () = exec' s in
      combine o
    in
    Sys.interactive := false;

    Toploop.input_name := "//toplevel//";
    let path =
      match !path with Some p -> p | None -> failwith "Path not set"
    in

    Topdirs.dir_directory path;

    Toploop.initialize_toplevel_env ();

    List.iter (fun f -> f ()) functions;
    exec' "open Stdlib";
    let header1 = Printf.sprintf "        %s version %%s" "OCaml" in
    exec' (Printf.sprintf "Format.printf \"%s@.\" Sys.ocaml_version;;" header1);
    exec' "#enable \"pretty\";;";
    exec' "#disable \"shortvar\";;";
    Sys.interactive := true;
    Logs.info (fun m -> m "Setup complete");
    {
      stdout = Buffer.contents stdout_buff;
      stderr = Buffer.contents stderr_buff;
    }

  let stdout_buff = Buffer.create 100
  let stderr_buff = Buffer.create 100

  let buff_opt b =
    match String.trim (Buffer.contents b) with "" -> None | s -> Some s

  let string_opt s = match String.trim s with "" -> None | s -> Some s

  let loc = function
    | Syntaxerr.Error x -> Some (Syntaxerr.location_of_error x)
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
    | _ -> None

  let execute printval ?pp_code ?highlight_location pp_answer s =
    let s =
      let l = String.length s in
      if String.sub s (l - 2) 2 = ";;" then s else s ^ ";;"
    in
    let lb = Lexing.from_function (refill_lexbuf s (ref 0) pp_code) in
    (try
       while true do
         try
           let phr = !Toploop.parse_toplevel_phrase lb in
           ignore (Toploop.execute_phrase printval pp_answer phr : bool)
         with
         | End_of_file -> raise End_of_file
         | x ->
             (match highlight_location with
             | None -> ()
             | Some f -> ( match loc x with None -> () | Some loc -> f loc));
             Errors.report_error Format.err_formatter x
       done
     with End_of_file -> ());
    flush_all ()

  let execute :
      string ->
      (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) IdlM.T.resultb =
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
      Buffer.clear code_buff;
      Buffer.clear res_buff;
      Buffer.clear stderr_buff;
      Buffer.clear stdout_buff;
      let o, () =
        S.capture
          (fun () -> execute true ~pp_code ~highlight_location pp_result phrase)
          ()
      in
      let mime_vals = Mime_printer.get () in
      Format.pp_print_flush pp_code ();
      Format.pp_print_flush pp_result ();
      IdlM.ErrM.return
        Toplevel_api_gen.
          {
            stdout = string_opt o.stdout;
            stderr = string_opt o.stderr;
            sharp_ppf = buff_opt code_buff;
            caml_ppf = buff_opt res_buff;
            highlight = !highlighted;
            mime_vals;
          }

  let filename_of_module unit_name =
    Printf.sprintf "%s.cmi" (String.uncapitalize_ascii unit_name)

  let get_dirs () =
    let {Load_path.visible; hidden} = Load_path.get_paths () in
    visible @ hidden

  let reset_dirs () =
    Ocaml_utils.Directory_content_cache.clear ();
    let open Ocaml_utils.Load_path in
    let dirs = get_dirs () in
    reset ();
    List.iter (fun p -> prepend_dir (Dir.create ~hidden:false p)) dirs

  let reset_dirs_comp () =
    let open Load_path in
    let dirs = get_dirs () in
    reset ();
    List.iter (fun p -> prepend_dir (Dir.create ~hidden:false p)) dirs

  let add_dynamic_cmis dcs =
    let fetch filename =
      let url = Filename.concat dcs.Toplevel_api_gen.dcs_url filename in
      S.sync_get url
    in
    let path =
      match !path with Some p -> p | None -> failwith "Path not set"
    in

    List.iter
      (fun name ->
        let filename = filename_of_module name in
        match fetch (filename_of_module name) with
        | Some content -> (
            let name = Filename.(concat path filename) in
            try S.create_file ~name ~content with _ -> ())
        | None -> ())
      dcs.dcs_toplevel_modules;

    let new_load : 'a 'b. string -> ('a -> string) -> (allow_hidden:bool -> unit_name:'a -> 'b option) -> allow_hidden:bool -> unit_name:'a -> 'b option
     = fun s to_string old_loader ~allow_hidden ~unit_name ->
      let unit_name_s = to_string unit_name in
      Logs.info (fun m -> m "%s Loading: %s" s unit_name_s);
      let filename = filename_of_module unit_name_s in

      let fs_name = Filename.(concat path filename) in
      (* Check if it's already been downloaded. This will be the
         case for all toplevel cmis. Also check whether we're supposed
         to handle this cmi *)
      if Sys.file_exists fs_name
      then Logs.info (fun m -> m "Found: %s" fs_name)
      else Logs.info (fun m -> m "No sign of %s locally" fs_name);
      if
        (not (Sys.file_exists fs_name))
        && List.exists
             (fun prefix -> String.starts_with ~prefix filename)
             dcs.dcs_file_prefixes
      then (
        Logs.info (fun m -> m "Fetching %s\n%!" filename);
        match fetch filename with
        | Some x ->
            S.create_file ~name:fs_name ~content:x;
            (* At this point we need to tell merlin that the dir contents
                 have changed *)
            if s = "merl" then reset_dirs () else reset_dirs_comp ()
        | None ->
            Printf.eprintf "Warning: Expected to find cmi at: %s\n%!"
              (Filename.concat dcs.Toplevel_api_gen.dcs_url filename));
      if s = "merl" then reset_dirs () else reset_dirs_comp ();
      old_loader ~allow_hidden ~unit_name
    in
    let furl = "file://" in
    let l = String.length furl in
    if String.length dcs.dcs_url > l && String.sub dcs.dcs_url 0 l = furl then
      let path = String.sub dcs.dcs_url l (String.length dcs.dcs_url - l) in
      Topdirs.dir_directory path
    else
      let open Persistent_env.Persistent_signature in
      let old_loader = !load in
      load := new_load "comp" Compilation_unit.Name.to_string old_loader;

      let open Ocaml_typing.Persistent_env.Persistent_signature in
      let old_loader = !load in
      load := new_load "merl" Ocaml_typing.Compilation_unit.Name.to_string old_loader

  let init (init_libs : Toplevel_api_gen.init_libs) =
    try
      Logs.info (fun m -> m "init()");
      path := Some init_libs.path;

      findlib_v := Some (S.findlib_init init_libs.findlib_index);

      (match S.get_stdlib_dcs init_libs.stdlib_dcs with
      | [ dcs ] -> add_dynamic_cmis dcs
      | _ -> ());
      Clflags.no_check_prims := true;
      List.iter
        (fun { Toplevel_api_gen.sc_name; sc_content } ->
          let filename =
            Printf.sprintf "%s.cmi" (String.uncapitalize_ascii sc_name)
          in
          let name = Filename.(concat init_libs.path filename) in
          S.create_file ~name ~content:sc_content)
        init_libs.cmis.static_cmis;
      List.iter add_dynamic_cmis init_libs.cmis.dynamic_cmis;

      S.import_scripts
        (List.map (fun cma -> cma.Toplevel_api_gen.url) init_libs.cmas);

      requires := init_libs.findlib_requires;
      functions :=
        Some
          (List.map
             (fun func_name ->
               Logs.info (fun m -> m "Function: %s" func_name);
               S.init_function func_name)
             (List.map (fun cma -> cma.Toplevel_api_gen.fn) init_libs.cmas));
      (* *)
      functions := Some [];
      Logs.info (fun m -> m "init() finished");

      IdlM.ErrM.return ()
    with e ->
      IdlM.ErrM.return_err
        (Toplevel_api_gen.InternalError (Printexc.to_string e))

  let setup () =
    try
      Logs.info (fun m -> m "setup() ...");

      let o =
        try
          match !functions with
          | Some l -> setup l ()
          | None -> failwith "Error: toplevel has not been initialised"
        with
        | Persistent_env.Error e ->
            Persistent_env.report_error Format.err_formatter e;
            let err = Format.asprintf "%a" Persistent_env.report_error e in
            failwith ("Error: " ^ err)
        | Env.Error e ->
            Env.report_error Format.err_formatter e;
            let err = Format.asprintf "%a" Env.report_error e in
            failwith ("Error: " ^ err)
      in

      let dcs =
        match !findlib_v with Some v -> S.require v !requires | None -> []
      in
      List.iter add_dynamic_cmis dcs;

      Logs.info (fun m -> m "setup() finished");

      IdlM.ErrM.return
        Toplevel_api_gen.
          {
            stdout = string_opt o.stdout;
            stderr = string_opt o.stderr;
            sharp_ppf = None;
            caml_ppf = None;
            highlight = None;
            mime_vals = [];
          }
    with e ->
      IdlM.ErrM.return_err
        (Toplevel_api_gen.InternalError (Printexc.to_string e))

  let complete _phrase = failwith "Not implemented"

  let typecheck_phrase :
      string ->
      (Toplevel_api_gen.exec_result, Toplevel_api_gen.err) IdlM.T.resultb = fun _ ->
        failwith "Not implemented"

  let split_primitives p =
    let len = String.length p in
    let rec split beg cur =
      if cur >= len then []
      else if Char.equal p.[cur] '\000' then
        String.sub p beg (cur - beg) :: split (cur + 1) (cur + 1)
      else split beg (cur + 1)
    in
    Array.of_list (split 0 0)

  let compile_js (_id : string option) _prog =
    (* try
      let l = Lexing.from_string prog in
      let phr = Parse.toplevel_phrase l in
      Typecore.reset_delayed_checks ();
      Env.reset_cache_toplevel ();
      Js_of_ocaml_compiler.Config.set_target `JavaScript;
      Js_of_ocaml_compiler.Config.set_effects_backend `Cps;
      let oldenv = !Toploop.toplevel_env in
      (* let oldenv = Compmisc.initial_env() in *)
      let phr = JsooTopPpx.preprocess_phrase phr in
      match phr with
      | Ptop_def sstr ->
          Logs.info (fun m -> m "Typing...");
          let str, sg, sn, _shape, newenv =
            try Typemod.type_toplevel_phrase oldenv sstr
            with Env.Error e ->
              Env.report_error Format.err_formatter e;
              (* exit 1 *)
              let err = Format.asprintf "%a" Env.report_error e in
              failwith ("Error: " ^ err)
          in
          Logs.info (fun m -> m "simplify...");
          let sg' = Typemod.Signature_names.simplify newenv sn sg in
          ignore (Includemod.signatures ~mark:Mark_positive oldenv sg sg');
          Typecore.force_delayed_checks ();
          Logs.info (fun m -> m "Translmod...");
          let lam = Translmod.transl_toplevel_definition str in
          Logs.info (fun m -> m "Simplif...");
          let slam = Simplif.simplify_lambda lam in
          Logs.info (fun m -> m "Bytegen...");
          let code, _can_free = Bytegen.compile_phrase slam in
          Logs.info (fun m -> m "Emitcode...");
          let code, reloc, _events = Emitcode.to_memory code in
          Toploop.toplevel_env := newenv;
          (* let prims = split_primitives (Symtable.data_primitive_names ()) in *)
          let b = Buffer.create 100 in
          let cmo =
            Cmo_format.
              {
                cu_name = Compunit "test";
                cu_pos = 0;
                cu_codesize = Bigarray.Array1.dim code;
                cu_reloc = reloc;
                cu_imports = [];
                cu_required_compunits = [];
                cu_primitives = [];
                cu_force_link = false;
                cu_debug = 0;
                cu_debugsize = 0;
              }
          in

          let fmt = Js_of_ocaml_compiler.Pretty_print.to_buffer b in
          (* Symtable.patch_object code reloc;
             Symtable.check_global_initialized reloc;
             Symtable.update_global_table(); *)
          let oc = open_out "/tmp/test.cmo" in
          Emitcode.marshal_to_channel_with_possibly_32bit_compat ~filename:"/tmp/test.cmo" ~kind:"bytecode unit" oc cmo;

          (* let code = String.init (Misc.LongString.length code) ~f:(fun i -> Misc.LongString.get code i) in *)
          close_out oc;
          (* Js_of_ocaml_compiler.Config.Flag.enable "pretty"; *)
          Js_of_ocaml_compiler.Driver.configure fmt;
          let ic = open_in "/tmp/test.cmo" in
          let p = Js_of_ocaml_compiler.Parse_bytecode.from_cmo cmo ic in
          let wrap_with_fun =
            match id with Some id -> `Named id | None -> `Iife
          in
          Js_of_ocaml_compiler.Driver.f' ~standalone:false ~wrap_with_fun
            ~link:`No fmt p.debug p.code;
          Format.(pp_print_flush std_formatter ());
          Format.(pp_print_flush err_formatter ());
          flush stdout;
          flush stderr;
          let js = Buffer.contents b in
          IdlM.ErrM.return js
      | _ -> IdlM.ErrM.return_err (Toplevel_api_gen.InternalError "Parse error")
    with e -> IdlM.ErrM.return ("Exception: %s" ^ Printexc.to_string e) *)
    failwith "Not implemented"

  let handle_toplevel stripped =
    if String.length stripped < 2 || stripped.[0] <> '#' || stripped.[1] <> ' '
    then (
      Printf.eprintf
        "Warning, ignoring toplevel block without a leading '# '.\n";
      IdlM.ErrM.return { Toplevel_api_gen.script = stripped; mime_vals = []; parts=[] })
    else
      let s = String.sub stripped 2 (String.length stripped - 2) in
      let list = Ocamltop.parse_toplevel s in
      let buf = Buffer.create 1024 in
      let mime_vals =
        List.fold_left
          (fun acc (phr, _junk, _output) ->
            let new_output =
              execute phr |> IdlM.T.get |> M.run |> Result.get_ok
            in
            Printf.bprintf buf "# %s\n" phr;
            let r =
              Option.to_list new_output.stdout
              @ Option.to_list new_output.stderr
              @ Option.to_list new_output.caml_ppf
            in
            let r =
              List.concat_map (fun l -> Astring.String.cuts ~sep:"\n" l) r
            in
            List.iter (fun x -> Printf.bprintf buf "  %s\n" x) r;
            let mime_vals = new_output.mime_vals in
            acc @ mime_vals)
          [] list
      in
      let content_txt = Buffer.contents buf in
      let content_txt =
        String.sub content_txt 0 (String.length content_txt - 1)
      in
      let result = { Toplevel_api_gen.script = content_txt; mime_vals; parts=[] } in
      IdlM.ErrM.return result

  let exec_toplevel (phrase : string) = handle_toplevel phrase

  let config () =
    let path =
      match !path with Some p -> p | None -> failwith "Path not set"
    in
    let initial = Merlin_kernel.Mconfig.initial in
    { initial with merlin = { initial.merlin with stdlib = Some path } }

  let make_pipeline source = Merlin_kernel.Mpipeline.make (config ()) source

  let wdispatch source query =
    let pipeline = make_pipeline source in
    Merlin_kernel.Mpipeline.with_pipeline pipeline @@ fun () ->
    Query_commands.dispatch pipeline query

  module Completion = struct
    open Merlin_utils
    open Std
    open Merlin_kernel

    (* Prefixing code from ocaml-lsp-server *)
    let rfindi =
      let rec loop s ~f i =
        if i < 0 then None
        else if f (String.unsafe_get s i) then Some i
        else loop s ~f (i - 1)
      in
      fun ?from s ~f ->
        let from =
          let len = String.length s in
          match from with
          | None -> len - 1
          | Some i ->
              if i > len - 1 then
                raise @@ Invalid_argument "rfindi: invalid from"
              else i
        in
        loop s ~f from

    let lsplit2 s ~on =
      match String.index_opt s on with
      | None -> None
      | Some i ->
          let open StdLabels.String in
          Some (sub s ~pos:0 ~len:i, sub s ~pos:(i + 1) ~len:(length s - i - 1))

    (** @see <https://ocaml.org/manual/lex.html> reference *)
    let prefix_of_position ?(short_path = false) source position =
      match Msource.text source with
      | "" -> ""
      | text ->
          let from =
            let (`Offset index) = Msource.get_offset source position in
            min (String.length text - 1) (index - 1)
          in
          let pos =
            let should_terminate = ref false in
            let has_seen_dot = ref false in
            let is_prefix_char c =
              if !should_terminate then false
              else
                match c with
                | 'a' .. 'z'
                | 'A' .. 'Z'
                | '0' .. '9'
                | '\'' | '_'
                (* Infix function characters *)
                | '$' | '&' | '*' | '+' | '-' | '/' | '=' | '>' | '@' | '^'
                | '!' | '?' | '%' | '<' | ':' | '~' | '#' ->
                    true
                | '`' ->
                    if !has_seen_dot then false
                    else (
                      should_terminate := true;
                      true)
                | '.' ->
                    has_seen_dot := true;
                    not short_path
                | _ -> false
            in
            rfindi text ~from ~f:(fun c -> not (is_prefix_char c))
          in
          let pos = match pos with None -> 0 | Some pos -> pos + 1 in
          let len = from - pos + 1 in
          let reconstructed_prefix = StdLabels.String.sub text ~pos ~len in
          (* if we reconstructed [~f:ignore] or [?f:ignore], we should take only
             [ignore], so: *)
          if
            String.is_prefixed ~by:"~" reconstructed_prefix
            || String.is_prefixed ~by:"?" reconstructed_prefix
          then
            match lsplit2 reconstructed_prefix ~on:':' with
            | Some (_, s) -> s
            | None -> reconstructed_prefix
          else reconstructed_prefix

    let at_pos source position =
      let prefix = prefix_of_position source position in
      let (`Offset to_) = Msource.get_offset source position in
      let from =
        to_
        - String.length (prefix_of_position ~short_path:true source position)
      in
      if prefix = "" then None
      else
        let query =
          Query_protocol.Complete_prefix (prefix, position, [], true, true)
        in
        Some (from, to_, wdispatch source query)
  end

  let mangle_toplevel is_toplevel orig_source deps =
    let src =
      if not is_toplevel then
        orig_source
      else
        if
          String.length orig_source < 2 || orig_source.[0] <> '#' || orig_source.[1] <> ' '
        then (Logs.err (fun m -> m "xx Warning, ignoring toplevel block without a leading '# '.\n%!"); orig_source)
        else begin
          try
            let s = String.sub orig_source 2 (String.length orig_source - 2) in
            let list = Ocamltop.parse_toplevel s in
            let buff = Buffer.create 100 in
            List.iter (fun (phr, junk, output) ->
            Printf.bprintf buff "  %s%s\n" phr (String.make (String.length junk) ' ');
            List.iter (fun x ->
              Printf.bprintf buff "  %s\n" (String.make (String.length x) ' ')) output) list;
            Buffer.contents buff
          with e ->
            Logs.err (fun m -> m "Error in mangle_toplevel: %s" (Printexc.to_string e));
            let ppf = Format.err_formatter in
            let _ = Location.report_exception ppf e in
            orig_source
          end
    in
    let line1 = List.map (fun id ->
      Printf.sprintf "open %s" (modname_of_id id)) deps |> String.concat " " in
    let line1 = line1 ^ ";;\n" in
    Logs.debug (fun m -> m "Line1: %s\n%!" line1);
    Logs.debug (fun m -> m "Source: %s\n%!" src);
    line1, src

  let complete_prefix _id _deps is_toplevel source position =
    let line1, src = mangle_toplevel is_toplevel source [] in
    let src= line1 ^ src in
    let source = Merlin_kernel.Msource.make src in
    let map_kind :
        [ `Value
        | `Constructor
        | `Variant
        | `Label
        | `Module
        | `Modtype
        | `Type
        | `MethodCall
        | `Keyword ] ->
        Toplevel_api_gen.kind_ty = function
      | `Value -> Value
      | `Constructor -> Constructor
      | `Variant -> Variant
      | `Label -> Label
      | `Module -> Module
      | `Modtype -> Modtype
      | `Type -> Type
      | `MethodCall -> MethodCall
      | `Keyword -> Keyword
    in
    let position =
      match position with
      | Toplevel_api_gen.Start -> `Offset (String.length line1)
      | Offset x -> `Offset (x + String.length line1)
      | Logical (x, y) -> `Logical (x + 1, y)
      | End -> `End
    in
    match Completion.at_pos source position with
    | Some (from, to_, compl) ->
        let entries =
          List.map
            (fun (entry : Query_protocol.Compl.entry) ->
              {
                Toplevel_api_gen.name = entry.name;
                kind = map_kind entry.kind;
                desc = entry.desc;
                info = entry.info;
                deprecated = entry.deprecated;
              })
            compl.entries
        in
        IdlM.ErrM.return { Toplevel_api_gen.from; to_; entries }
    | None ->
        IdlM.ErrM.return { Toplevel_api_gen.from = 0; to_ = 0; entries = [] }

  let add_cmi id deps source =
    Logs.info (fun m -> m "add_cmi");
    let dep_modules = List.map modname_of_id deps in
    let loc = Location.none in
    let path =
      match !path with Some p -> p | None -> failwith "Path not set"
    in
    let filename = modname_of_id id |> String.uncapitalize_ascii in
    let prefix = Printf.sprintf "%s/%s" path filename in
    let filename = Printf.sprintf "%s.ml" prefix in
    Logs.info (fun m -> m "prefix: %s\n%!" prefix);
    let oc = open_out filename in
    Printf.fprintf oc "%s" source;
    close_out oc;
    (try Sys.remove (prefix ^ ".cmi") with e -> Logs.err (fun m -> m "Error removing %s: %s" filename (Printexc.to_string e)));
    let unit_info = Unit_info.make ~source_file:filename prefix in
    try
      let store = Local_store.fresh () in
      Local_store.with_store store (fun () ->
        Local_store.reset ();
        let env = Typemod.initial_env ~loc ~initially_opened_module:(Some "Stdlib") ~open_implicit_modules:dep_modules in
        let lexbuf = Lexing.from_string source in
        let ast = Parse.implementation lexbuf in
        Logs.info (fun m -> m "About to type_implementation");
        let _ = Typemod.type_implementation unit_info (Compilation_unit.of_string (modname_of_id id)) env ast in
        let b = Sys.file_exists (prefix ^ ".cmi") in
        Logs.info (fun m -> m "file_exists: %s = %b\n%!" (prefix ^ ".cmi") b));
      (* reset_dirs () *) ()
    with exn ->
      let s = Printexc.to_string exn in
      Logs.err (fun m -> m "Error in add_cmi: %s" s);
      Logs.err (fun m -> m "Backtrace: %s" (Printexc.get_backtrace ()));
      let ppf = Format.err_formatter in
      let _ = Location.report_exception ppf exn in
      ()
  

  let map_pos line1 pos =
                Lexing.{ pos with
                  pos_bol = pos.pos_bol - String.length line1;
                    pos_lnum = pos.pos_lnum - 1;
                    pos_cnum = pos.pos_cnum - String.length line1;
                  }

  let map_loc line1 (loc : Ocaml_parsing.Location.t) =
                  { loc with
                 Ocaml_utils.Warnings.loc_start = map_pos line1 loc.loc_start;
                  Ocaml_utils.Warnings.loc_end = map_pos line1 loc.loc_end;
                }

  let query_errors id deps is_toplevel orig_source =
    try
      Logs.info (fun m -> m "About to mangle toplevel");
      let line1, src = mangle_toplevel is_toplevel orig_source deps in
      let id = Option.get id in
      let source = Merlin_kernel.Msource.make (line1 ^ src) in
      let query =
        Query_protocol.Errors { lexing = true; parsing = true; typing = true }
      in
      let errors =
        wdispatch source query
        |> StdLabels.List.map
             ~f:(fun
                 (Ocaml_parsing.Location.{ kind; main = _; sub; source } as
                  error)
               ->
               let of_sub sub =
                 Ocaml_parsing.Location.print_sub_msg Format.str_formatter sub;
                 String.trim (Format.flush_str_formatter ())
               in
               let loc = map_loc line1 (Ocaml_parsing.Location.loc_of_report error) in

               let main =
                 Format.asprintf "@[%a@]" Ocaml_parsing.Location.print_main
                   error
                 |> String.trim
               in
               {
                 Toplevel_api_gen.kind;
                 loc;
                 main;
                 sub = StdLabels.List.map ~f:of_sub sub;
                 source;
               })
      in
      if List.length errors = 0 then
        add_cmi id deps src;
      Logs.info (fun m -> m "Got to end");
      IdlM.ErrM.return errors
    with e ->
      Logs.info (fun m -> m "Error: %s" (Printexc.to_string e));
      IdlM.ErrM.return_err
        (Toplevel_api_gen.InternalError (Printexc.to_string e))

  let type_enclosing _id deps is_toplevel orig_source position =
    let line1, src = mangle_toplevel is_toplevel orig_source deps in
    let src = line1 ^ src in
    let position =
      match position with
      | Toplevel_api_gen.Start -> `Start
      | Offset x -> `Offset (x + String.length line1)
      | Logical (x, y) -> `Logical (x+1, y)
      | End -> `End
    in
    let source = Merlin_kernel.Msource.make src in
    let query = Query_protocol.Type_enclosing (None, position, None) in
    let enclosing = wdispatch source query in
    let map_index_or_string = function
      | `Index i -> Toplevel_api_gen.Index i
      | `String s -> String s
    in
    let map_tail_position = function
      | `No -> Toplevel_api_gen.No
      | `Tail_position -> Tail_position
      | `Tail_call -> Tail_call
    in
    let enclosing =
      List.map
        (fun (x, y, z) -> (x, map_index_or_string y, map_tail_position z))
        enclosing
    in
    IdlM.ErrM.return enclosing
end
