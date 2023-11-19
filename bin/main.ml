open Tyxml

let write_html_to_file filename html_node =
  let rendered_html = Format.asprintf "%a" (Html.pp ~indent:true ()) html_node in
  let oc = open_out filename in
  output_string oc rendered_html ; close_out oc

let get_head =
  let open Html in
  head
    (title (txt "TyXML"))
    [ link ~rel:[`Stylesheet] ~href:"https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.min.css" ()
    ; link ~rel:[`Stylesheet] ~href:"https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/theme/black.min.css" ()
    ; script ~a:[a_src "https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.min.js"] (txt "")
    ; script ~a:[a_src "https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/plugin/markdown/markdown.js"] (txt "")
    ; script ~a:[a_src "https://cdn.jsdelivr.net/npm/reveal.js-mermaid-plugin@2.0.0/plugin/mermaid/mermaid.js"] (txt "")
    ; script ~a:[a_src "static/init_reveal.js"] (txt "")
    ; script ~a:[a_src "https://d3js.org/d3.v5.min.js"] (txt "") ]

let get_slides_content =
  let open Html in
  div
    ~a:[a_class ["slides"]]
    [ section [h1 [txt "TyXML"]]
    ; section
        ~a:[a_user_data "transition" "fade-in"]
        [ div
            ~a:[a_class ["mermaid"]]
            [ pre
                [ txt
                    " \n\
                    \     %%{init: {'theme': 'dark', 'themeVariables': { 'darkMode': true }}}%%\n\
                    \          flowchart TD  \n\
                    \            A[Start] --> B{Is it?};\n\
                    \            B -- No ----> E[End];\n\n\
                    \    " ] ] ]
    ; section
        ~a:[a_user_data "transition" "fade-in"]
        [ div
            ~a:[a_class ["mermaid"]]
            [ pre
                [ txt
                    " \n\
                    \     %%{init: {'theme': 'dark', 'themeVariables': { 'darkMode': true }}}%%\n\
                    \          flowchart TD  \n\
                    \            A[Start] --> B{Is it?};\n\
                    \            B -- Yes --> C[OK];\n\
                    \            C --> D[Rethink];\n\
                    \            D --> B;\n\
                    \            B -- No ----> E[End];\n\n\
                    \    " ] ] ]
    ; section
        ~a:[a_user_data "markdown" ""]
        [ textarea
            ~a:[a_user_data "template" ""]
            (txt
               "\n\
               \    ## Slide 1\n\
               \    A paragraph with some text and a [link](https://hakim.se).\n\
               \    ---\n\
               \    ## Slide 2\n\
               \    ---\n\
               \    ## Slide 3\n\
               \    - Item 1\n\
               \    - Item 2\n\
               \     ```js [1-2|3|4]\n\
               \    let a = 1;\n\
               \    let b = 2;\n\
               \    let c = x => 1 + 2 + x;\n\
               \    c(3);\n\
               \    ```\n\
               \    " ) ]
    ; MyPro.get_d3_slide
    ; section
        [ form
            ~a:[a_method `Post; a_action "/feedback"]
            [ label ~a:[a_label_for "what-you-think"] [txt "Tell us what you think!"]
            ; input ~a:[a_name "what-you-think"; a_id "what-you-think"] ()
            ; input ~a:[a_input_type `Submit; a_value "Send"] () ] ] ]

let get_body =
  let open Html in
  body [div ~a:[a_class ["reveal"]] [get_slides_content]]

let page =
  let open Html in
  html get_head get_body

let () =
  (* let b=  Slides.Test.lal2 in *)
  write_html_to_file "index.html" page ;
  Dream.run @@ Dream.logger @@ Dream_livereload.inject_script ()
  @@ Dream.router
       [ Dream_livereload.route ()
       ; Dream.get "/static/**" @@ Dream.static "static/"
       ; Dream.get "/" (fun _ ->
             Dream.respond ~headers:[("Content-Type", "text/html")] (Format.asprintf "%a" (Tyxml.Html.pp ()) page) ) ]
