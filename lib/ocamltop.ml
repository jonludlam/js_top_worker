let refill_lexbuf s p buffer len =
  if !p = String.length s then 0
  else
    let len' =
      try String.index_from s !p '\n' - !p + 1 with _ -> String.length s - !p
    in
    let len'' = min len len' in
    String.blit s !p buffer 0 len'';
    p := !p + len'';
    len''

let parse_toplevel s =
  let legacy_warn =
    let b = ref false in
    fun () ->
      if !b
      then ()
      else
        (Logs.warn (fun m -> m "Warning: Legacy toplevel output detected");
        b := true)
  in

  let lexbuf = Lexing.from_string s in
  let rec loop pos =
    let _phr = !Toploop.parse_toplevel_phrase lexbuf in
    let new_pos = Lexing.lexeme_end lexbuf in
    let phr = String.sub s pos (new_pos - pos) in
    let (junk, (cont, is_legacy, output)) = Toplexer.entry lexbuf in
    let output =
      if is_legacy then begin
        legacy_warn ();
        output
      end else output
    in
    let new_pos = Lexing.lexeme_end lexbuf in
    if cont then (phr, junk, output) :: loop new_pos else [ (phr, junk, output) ]
  in
  loop 0
