let add a b = a + b

let%test _ = add 5 2 == 7

open Tyxml

let get_d3_slide =
  let open Html in
  section
    [ div ~a:[a_id "d3-chart"] []
    ; button ~a:[a_onclick "triggerD3Animation();"] [txt "Animate Chart"]
    ; script ~a:[a_src "static/d3_script.js"] (txt "") ]
