  $ ./script.sh
  cli: internal error, uncaught exception:
       End_of_file
       Raised at Stdlib.unsafe_really_input in file "stdlib.ml", line 429, characters 9-26
       Called from Dune__exe__Unix_client.binary_rpc in file "example/unix_client.ml", line 20, characters 2-30
       Called from Cmdlinergen.Gen.declare_.generate.inner.run in file "src/lib/cmdlinergen.ml", line 185, characters 27-35
       Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
       Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  Fatal error: exception Idl.MarshalError("No value found for key: 'execute' when unmarshalling 'init_config'")
  Raised at Idl.IdM.fail in file "src/lib/idl.ml", line 425, characters 15-22
  Called from Dune__exe__Unix_worker.start_server.process in file "example/unix_worker.ml", line 167, characters 4-62
  Called from Dune__exe__Unix_worker.binary_handler in file "example/unix_worker.ml", line 63, characters 2-17
  Called from Dune__exe__Unix_worker.serve_requests.(fun) in file "example/unix_worker.ml", line 92, characters 8-44
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Dune__exe__Unix_worker.serve_requests in file "example/unix_worker.ml", lines 86-92, characters 4-54
  Called from Dune__exe__Unix_worker in file "example/unix_worker.ml", line 172, characters 8-23
  cli: internal error, uncaught exception:
       End_of_file
       Raised at Stdlib.unsafe_really_input in file "stdlib.ml", line 429, characters 9-26
       Called from Dune__exe__Unix_client.binary_rpc in file "example/unix_client.ml", line 20, characters 2-30
       Called from Cmdlinergen.Gen.declare_.generate.inner.run in file "src/lib/cmdlinergen.ml", line 185, characters 27-35
       Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
       Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  cli: internal error, uncaught exception:
       Unix.Unix_error(Unix.ECONNREFUSED, "connect", "")
       Raised by primitive operation at Dune__exe__Unix_client.binary_rpc in file "example/unix_client.ml", line 11, characters 2-25
       Called from Cmdlinergen.Gen.declare_.generate.inner.run in file "src/lib/cmdlinergen.ml", line 185, characters 27-35
       Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
       Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  cli: internal error, uncaught exception:
       Unix.Unix_error(Unix.ECONNREFUSED, "connect", "")
       Raised by primitive operation at Dune__exe__Unix_client.binary_rpc in file "example/unix_client.ml", line 11, characters 2-25
       Called from Cmdlinergen.Gen.declare_.generate.inner.run in file "src/lib/cmdlinergen.ml", line 185, characters 27-35
       Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
       Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  cli: internal error, uncaught exception:
       Unix.Unix_error(Unix.ECONNREFUSED, "connect", "")
       Raised by primitive operation at Dune__exe__Unix_client.binary_rpc in file "example/unix_client.ml", line 11, characters 2-25
       Called from Cmdlinergen.Gen.declare_.generate.inner.run in file "src/lib/cmdlinergen.ml", line 185, characters 27-35
       Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
       Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  ./script.sh: line 17: kill: (32735) - No such process
  [1]
