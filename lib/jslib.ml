let log fmt =
  Format.kasprintf
    (fun s -> Js_of_ocaml.(Console.console##log (Js.string s)))
    fmt

let sync_get url =
  let open Js_of_ocaml in
  let global_rel_url =
    let x : Js.js_string Js.t option = Js.Unsafe.js_expr "globalThis.__global_rel_url" |> Js.Optdef.to_option in
    Option.map Js.to_string x
  in
  let url =
    match global_rel_url with
    | Some rel -> Filename.concat rel url
    | None -> url
  in
  Console.console##log (Js.string ("Fetching: " ^ url));
  let x = XmlHttpRequest.create () in
  x##.responseType := Js.string "arraybuffer";
  x##_open (Js.string "GET") (Js.string url) Js._false;
  x##send Js.null;
  match x##.status with
  | 200 ->
      Js.Opt.case
        (File.CoerceTo.arrayBuffer x##.response)
        (fun () ->
          Console.console##log (Js.string "Failed to receive file");
          None)
        (fun b -> Some (Typed_array.String.of_arrayBuffer b))
  | _ -> None
