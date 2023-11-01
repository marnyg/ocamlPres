open Tyxml

let write_html_to_file filename html_node =
  let rendered_html = Format.asprintf "%a" (Html.pp ~indent:true ()) html_node in
  let oc = open_out filename in
  output_string oc rendered_html ; close_out oc

let get_head =
  let open Html in
  head
    (title (txt "TyXML"))
    [ link ~rel:[`Stylesheet] ~href:"https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2/css/reveal.min.css" ()
    ; script ~a:[a_src "https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2/js/reveal.min.js"] (txt "")
    ; script ~a:[a_src "https://d3js.org/d3.v5.min.js"] (txt "") ]

let get_body =
  let open Html in
  body
    [ h1 [txt "TyXML"]
    ; p [txt "Is cool!"]
    ; form
        ~a:[a_method `Post; a_action "/feedback"]
        [ label ~a:[a_label_for "what-you-think"] [txt "Tell us what you think!"]
        ; input ~a:[a_name "what-you-think"; a_id "what-you-think"] ()
        ; input ~a:[a_input_type `Submit; a_value "Send"] () ] ]

let page =
  let open Html in
  html get_head get_body

let () =
  write_html_to_file "index.html" page ;
  Dream.run @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun _ ->
             Dream.respond ~headers:[("Content-Type", "text/html")] (Format.asprintf "%a" (Tyxml.Html.pp ()) page) ) ]
