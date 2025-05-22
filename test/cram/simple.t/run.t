  $ ./script.sh
  unix_worker: [INFO] init()
  unix_worker: [INFO] init() finished
  N
  unix_worker: [INFO] setup() ...
  unix_worker: [INFO] Setup complete
  unix_worker: [INFO] setup() finished
  {mime_vals:[];stderr:S(error while evaluating #enable "pretty";;
  error while evaluating #disable "shortvar";;);stdout:S(OCaml version 5.2.0
  Unknown directive enable.
  Unknown directive disable.)}
  {mime_vals:[];parts:[];script:S(# Printf.printf "Hello, world\n";;
    Hello, world
    - : unit = ())}
  {mime_vals:[];parts:[];script:S(# let x = 1 + 2;;
    val x : int = 3
  # let x = 2+3;;
    val x : int = 5)}
  {mime_vals:[];parts:[];script:S(# let x = 1 + 2;;
    val x : int = 3
  # let x = 2+3;;
    val x : int = 5)}
