{ }

(* TODO: implement strings, comments, etc, to ignore ';;' in them *)
rule fallback_expression = shortest
    | (_ as expr)* ";;" {
        expr
    }
    | (_ as expr)* eof {
        expr
    }

and entry = parse
    | ((_ # '\n')* as junk) "\n" {
        (junk, line_prefix [] lexbuf)
    }
    | ((_ # '\n')* as junk) eof {
        (junk, (false, []))
    }

and line_prefix acc = parse
    | "# " {
        true, List.rev acc
    }
    | _ as c {
        output_line_legacy c acc lexbuf
    }
    | eof {
        false, List.rev ("" :: acc)
    }

and output_line_legacy c acc = parse
    | ((_ # '\n')* as line) "\n# " {
        true, List.rev ((String.make 1 c ^ line) :: acc)
    }
    | ((_ # '\n')* as line) "\n" (_ as c') {
        output_line_legacy c' ((String.make 1 c ^ line) :: acc) lexbuf
    }
    | ((_ # '\n')* as line) "\n" eof {
        false, List.rev ("" :: (String.make 1 c ^ line) :: acc) 
    }
    | (_ # '\n')* as line eof {
        false, List.rev ((String.make 1 c ^ line) :: acc)
    }

