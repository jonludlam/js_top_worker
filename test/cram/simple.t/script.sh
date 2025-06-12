#!/bin/bash


export OCAMLRUNPARAM=b

unix_worker &
pid=$!

sleep 1

unix_client init '{ findlib_requires:[], execute: true }'
unix_client setup 
unix_client exec_toplevel '# Printf.printf "Hello, world\n";;'
unix_client exec_toplevel "$(cat s1)"
unix_client exec_toplevel "$(cat s2)"

kill $pid

