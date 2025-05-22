
let triple f1 f2 f3 ppf (v1, v2, v3) =
  Format.fprintf ppf "(%a,%a,%a)" f1 v1 f2 v2 f3 v3
let fmt = Fmt.Dump.(list (triple string string (list string)))

let print phr =
  Format.printf "%a" fmt phr

let check phrase =
  let output = snd (Js_top_worker.Impl.mangle_toplevel true phrase []) in 
  print_endline "input:";
  print_endline phrase;
  print_endline "output:";
  print_endline output;
  let output_mapped = String.map (fun c -> if c = ' ' then '.' else c) output in
  print_endline "output mapped:";
  print_endline output_mapped

let%expect_test _ =
  check "# foo;; junk\n  bar\n# baz;;\n  moo\n# unterminated;; foo\n";
  [%expect{|
    input:
    # foo;; junk
      bar
    # baz;;
      moo
    # unterminated;; foo

    output:
      foo;;

      baz;;

      unterminated;;

    output mapped:
    ..foo;;.....
    .....
    ..baz;;
    .....
    ..unterminated;;.... |}]

let%expect_test _ =
  check "# 1+2;;\n- 3 : int\n  \n";
  [%expect{|
    input:
    # 1+2;;
    - 3 : int


    output:
      1+2;;



    output mapped:
    ..1+2;;
    .........
    .. |}]
  
let%expect_test _ =
  check "# 1+2;;";
  [%expect{|
    input:
    # 1+2;;
    output:
      1+2;;
    output mapped:
    ..1+2;; |}]

let%expect_test _ =
  check "# 1+2;;\nx\n";
  [%expect{|
    input:
    # 1+2;;
    x

    output:
      1+2;;


    output mapped:
    ..1+2;;
    . |}]

let%expect_test _ =
  check "# let ;;\n  foo";
  [%expect "
    fallback parser
    Got phrase
    input:
    # let ;;
      foo
    output:
      let ;;

    output mapped:
    ..let.;;
    ....."]