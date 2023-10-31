let write_html_to_file filename html_node =
  let rendered_html = Format.asprintf "%a" Dream_html.pp html_node in
  let oc = open_out filename in
  output_string oc rendered_html ;
  close_out oc

let page =
  let open Dream_html in
  let open HTML in
  html
    [lang "en"]
    [ head [] [title [] "Dream-html"]
    ; body []
        [ h1 [] [txt "Dream-html"]
        ; p [] [txt "Is cool!"]
        ; form
            [method_ `POST; action "/feedback"]
            [ label [for_ "what-you-think"] [txt "Tell us what you think!"]
            ; input [name "what-you-think"; id "what-you-think"]
            ; input [type_ "submit"; value "Send"] ] ] ]

let () =
  write_html_to_file "index.html" page ;
  Dream.run @@ Dream.logger
  @@ Dream.router [Dream.get "/" (fun _ -> Dream_html.respond page)]
(* @@ Dream.not_found; *)
