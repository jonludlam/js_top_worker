#!/bin/bash

mkdir -p lib/ocaml
cp $OPAM_SWITCH_PREFIX/lib/ocaml/*.cmi lib/ocaml/
mkdir -p lib/stringext
cp $OPAM_SWITCH_PREFIX/lib/stringext/META lib/stringext
cp $OPAM_SWITCH_PREFIX/lib/stringext/*.cmi lib/stringext

js_of_ocaml $OPAM_SWITCH_PREFIX/lib/stringext/stringext.cma -o lib/stringext/stringext.cma.js --effects cps

cat > lib/ocaml/dynamic_cmis.json << EOF
{
  dcs_url: "/lib/ocaml/",
  dcs_toplevel_modules: ["CamlinternalOO","Stdlib","CamlinternalFormat","Std_exit","CamlinternalMod","CamlinternalFormatBasics","CamlinternalLazy"],
  dcs_file_prefixes : ["stdlib__"]
}
EOF

cat > lib/stringext/dynamic_cmis.json << EOF
{
  dcs_url: "/lib/stringext/",
  dcs_toplevel_modules: ["Stringext"],
  dcs_file_prefixes : []
}
EOF

find lib -name "META" > lib/findlib_index

