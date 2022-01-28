# An OCaml toplevel designed to run in a web worker

To run the example, the worker needs to be served by an http server rather
than loaded from the filesystem. Therefore the example may be run in the
following way:

```
$ dune build
$ cd _build/default/example
$ python3 -m http.server 8000
```

and then opening the URL `http://localhost:8000/`
