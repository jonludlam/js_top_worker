(lang dune 3.0)

(name js-top-worker)

(package
 (name js-top-worker)
 (synopsis "JavaScript Toplevel worker")
 (description "An OCaml toplevel designed to run as a web worker")
 (depends
  (ocaml
   (>= 4.08.0))
  (js_of_ocaml
   (>= 3.11.0))
  rresult
  brr
  lwt
  astring
  ppx_deriving_rpc
  js_of_ocaml-toplevel
  js_of_ocaml-compiler
  js_of_ocaml-ppx))
