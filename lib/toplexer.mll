{ }

rule entry = parse
    | ((_ # '\n')* as junk) "\n" {
        (junk, line_prefix [] lexbuf)
    }
    | ((_ # '\n')* as junk) {
        (junk, (false, false, []))
    }
    | ((_ # '\n')* as junk) eof { (junk, (false, false, [])) }

and line_prefix acc = parse
    | "  " {
        line acc lexbuf
    }
    | "# " {
        true, false, List.rev acc
    }
    | _ as c {
        output_line_legacy c acc lexbuf
    }
    | eof {
        false, false, List.rev acc
    }

and line acc = parse
    | ((_ # '\n')* as line) "\n" {
        line_prefix (("  "^line) :: acc) lexbuf
    }
    | ((_ # '\n')* as line) eof {
        false, false, List.rev (("  "^line) :: acc)
    }

and output_line_legacy c acc = parse
    | ((_ # '\n')* as line) "\n# " {
        true, true, List.rev ((String.make 1 c ^ line) :: acc)
    }
    | ((_ # '\n')* as line) "\n" (_ as c') {
        output_line_legacy c' ((String.make 1 c ^ line) :: acc) lexbuf
    }
    | ((_ # '\n')* as line) "\n" eof {
        false, true, List.rev ("" :: (String.make 1 c ^ line) :: acc) 
    }
    | (_ # '\n')* as line eof {
        false, true, List.rev ((String.make 1 c ^ line) :: acc)
    }
    | eof {
        false, true, List.rev ((String.make 1 c) :: acc)
    }

