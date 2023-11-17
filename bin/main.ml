open Tyxml

let write_html_to_file filename html_node =
  let rendered_html = Format.asprintf "%a" (Html.pp ~indent:true ()) html_node in
  let oc = open_out filename in
  output_string oc rendered_html ; close_out oc

let get_head =
  let open Html in
  head
    (title (txt "TyXML"))
    [ link ~rel:[`Stylesheet] ~href:"https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.css" ()
    ; script ~a:[a_src "https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.js"] (txt "")
    ; script ~a:[a_src "https://d3js.org/d3.v5.min.js"] (txt "")
    ; script ~a:[a_src "slides/main.js"] (txt "") ]

let get_slides_content =
  let open Html in
  div
    ~a:[a_class ["slides"]]
    [ section [h1 [txt "TyXML"]]
    ; section [p [txt "Is cool!"]]
    ; MyPro.get_d3_slide
    ; section
        [ form
            ~a:[a_method `Post; a_action "/feedback"]
            [ label ~a:[a_label_for "what-you-think"] [txt "Tell us what you think!"]
            ; input ~a:[a_name "what-you-think"; a_id "what-you-think"] ()
            ; input ~a:[a_input_type `Submit; a_value "Send"] () ] ] ]

let get_body =
  let open Html in
  body
    [ div
        ~a:[a_class ["reveal"]]
        [ get_slides_content
        ; script
            (txt
               "\n\
               \        document.addEventListener('DOMContentLoaded', function() {\n\
               \          Reveal.initialize({ });\n\
               \        });\n\
               \      " ) ] ]

let page =
  let open Html in
  html get_head get_body

let () =
  (* let b=  Slides.Test.lal2 in *)
  write_html_to_file "index.html" page ;
  Dream.run @@ Dream.logger @@ Dream_livereload.inject_script ()
  @@ Dream.router
       [ Dream_livereload.route ()
       ; Dream.get "/slides/**" @@ Dream.static "_build/default/bin/"
       (* ; Dream.get "/slides/**" @@ Dream.static "_build/default/lib/slides" *)
       ; Dream.get "/" (fun _ ->
             Dream.respond ~headers:[("Content-Type", "text/html")] (Format.asprintf "%a" (Tyxml.Html.pp ()) page) ) ]
