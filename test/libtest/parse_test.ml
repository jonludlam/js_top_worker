
let triple f1 f2 f3 ppf (v1, v2, v3) =
  Format.fprintf ppf "(%a,%a,%a)" f1 v1 f2 v2 f3 v3
let fmt = Fmt.Dump.(list (triple string string (list string)))

let print phr =
  Format.printf "%a" fmt phr

let check phrase =
  let output = snd (Js_top_worker.Impl.mangle_toplevel true phrase []) in 
  print_endline "input:";
  Printf.printf "{|%s|}\n" phrase;
  print_endline "output:";
  Printf.printf "{|%s|}\n" output;
  let output_mapped = String.map (fun c -> if c = ' ' then '.' else c) output in
  print_endline "output mapped:";
  Printf.printf "{|%s|}\n" output_mapped

let%expect_test _ =
  check "# foo;; junk\n  bar\n# baz;;\n  moo\n# unterminated;; foo\n";
  [%expect{xxx|
    input:
    {|# foo;; junk
      bar
    # baz;;
      moo
    # unterminated;; foo
    |}
    output:
    {|  foo;;

      baz;;

      unterminated;;
    |}
    output mapped:
    {|..foo;;.....
    .....
    ..baz;;
    .....
    ..unterminated;;....
    |}
    |xxx}]

let%expect_test _ =
  check "# 1+2;;\n- 3 : int\n  \n";
  [%expect{xxx|
    input:
    {|# 1+2;;
    - 3 : int

    |}
    output:
    {|  1+2;;


    |}
    output mapped:
    {|..1+2;;
    .........
    ..
    |}
    |xxx}]
  
let%expect_test _ =
  check "# 1+2;;";
  [%expect{xxx|
    input:
    {|# 1+2;;|}
    output:
    {|  1+2;;|}
    output mapped:
    {|..1+2;;|}
    |xxx}]

let%expect_test _ =
  check "# 1+2;;\nx\n";
  [%expect{xxx|
    input:
    {|# 1+2;;
    x
    |}
    output:
    {|  1+2;;

    |}
    output mapped:
    {|..1+2;;
    .
    |}
    |xxx}]

let%expect_test _ =
  check "# let ;;\n  foo";
  [%expect " 
 fallback parser
 Got phrase
 input:
 {|# let ;;
   foo|}
 output:
 {|  let ;;
      |}
 output mapped:
 {|..let.;;
 .....|}
 "]

  
let%expect_test _ =
  check "# let x=1;;\n  foo\n\n# let y=2;;\n  bar\n\n";
  [%expect " 
 input:
 {|# let x=1;;
   foo

 # let y=2;;
   bar

 |}
 output:
 {|  let x=1;;


   let y=2;;


 |}
 output mapped:
 {|..let.x=1;;
 .....

 ..let.y=2;;
 .....

 |}
 "]