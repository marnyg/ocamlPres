let page =
  let open Dream_html in
  let open HTML in
  html [lang "en"] [
    head [] [
      title [] "Dream-html" ];
    body [] [
      h1 [] [txt "Dream-html"];
      p [] [txt "Is cool!"];
      form [method_ `POST; action "/feedback"] [

        label [for_ "what-you-think"] [txt "Tell us what you think!"];
        input [name "what-you-think"; id "what-you-think"];
        input [type_ "submit"; value "Send"] ] ] ]

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _ ->(Dream_html.respond page ))
  ]
