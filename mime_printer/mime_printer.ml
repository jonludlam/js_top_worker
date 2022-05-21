type encoding = Noencoding | Base64
type t = { mime_type : string; encoding : encoding; data : string }

let outputs : t list ref = ref []

let push ?(encoding = Noencoding) mime_type data =
  outputs := { mime_type; encoding; data } :: !outputs

let get () =
  let result = !outputs in
  outputs := [];
  result
