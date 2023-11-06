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
    ; script ~a:[a_src "https://d3js.org/d3.v5.min.js"] (txt "") ]

let get_d3_slide =
  let open Html in
  section
    [ div ~a:[a_id "d3-chart"] []
    ; (* Placeholder for the D3 chart *)
      button ~a:[a_onclick "triggerD3Animation();"] [txt "Animate Chart"]
    ; script
        (txt
           "\n\
           \      var y; // Define y at a higher scope level to be accessible by both functions\n\
           \      function triggerD3Animation() {\n\
           \        // Select all bars and apply a transition\n\
           \        d3.selectAll('.bar')\n\
           \          .transition()\n\
           \          .duration(750)\n\
           \          .attr('y', function(d) { return y(d.value) - 10; }) // Small bounce effect\n\
           \          .attr('height', function(d) { return height - y(d.value) + 10; })\n\
           \          .transition()\n\
           \          .duration(750)\n\
           \          .attr('y', function(d) { return y(d.value); }) // Return to original position\n\
           \          .attr('height', function(d) { return height - y(d.value); });\n\
           \      }\n\
           \      \n\
           \      function createD3Chart() {\n\
           \        // Simple D3.js bar chart example\n\
           \        var data = [{label: 'A', value: 30}, {label: 'B', value: 80}, {label: 'C', value: 45}];\n\
           \        \n\
           \        var svg = d3.select('#d3-chart').append('svg')\n\
           \          .attr('width', 400)\n\
           \          .attr('height', 300);\n\n\
           \        var margin = {top: 20, right: 20, bottom: 30, left: 40},\n\
           \            width = +svg.attr('width') - margin.left - margin.right,\n\
           \            height = +svg.attr('height') - margin.top - margin.bottom;\n\n\
           \        var x = d3.scaleBand().rangeRound([0, width]).padding(0.1)\n\
           \        y = d3.scaleLinear().rangeRound([height, 0]);\n\n\
           \        var g = svg.append('g')\n\
           \          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');\n\n\
           \        x.domain(data.map(function(d) { return d.label; }));\n\
           \        y.domain([0, d3.max(data, function(d) { return d.value; })]);\n\n\
           \        g.append('g')\n\
           \          .attr('class', 'axis axis--x')\n\
           \          .attr('transform', 'translate(0,' + height + ')')\n\
           \          .call(d3.axisBottom(x));\n\n\
           \        g.append('g')\n\
           \          .attr('class', 'axis axis--y')\n\
           \          .call(d3.axisLeft(y).ticks(10, '%'))\n\
           \          .append('text')\n\
           \          .attr('transform', 'rotate(-90)')\n\
           \          .attr('y', 6)\n\
           \          .attr('dy', '0.71em')\n\
           \          .attr('text-anchor', 'end')\n\
           \          .text('Value');\n\n\
           \        g.selectAll('.bar')\n\
           \          .data(data)\n\
           \          .enter().append('rect')\n\
           \          .attr('class', 'bar')\n\
           \          .attr('x', function(d) { return x(d.label); })\n\
           \          .attr('y', function(d) { return y(d.value); })\n\
           \          .attr('width', x.bandwidth())\n\
           \          .attr('height', function(d) { return height - y(d.value); });\n\
           \      }\n\n\
           \      document.addEventListener('DOMContentLoaded', function() {\n\
           \        createD3Chart();\n\
           \        Reveal.addEventListener('slidechanged', function(event) {\n\
           \          if (event.currentSlide.getAttribute('data-state') === 'd3-slide') {\n\
           \            createD3Chart();\n\
           \          }\n\
           \        });\n\
           \      });\n\
           \    " ) ]

let get_slides_content =
  let open Html in
  div
    ~a:[a_class ["slides"]]
    [ section [h1 [txt "TyXML"]]
    ; section [p [txt "Is cool!"]]
    ; get_d3_slide
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
  write_html_to_file "index.html" page ;
  Dream.run @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun _ ->
             Dream.respond ~headers:[("Content-Type", "text/html")] (Format.asprintf "%a" (Tyxml.Html.pp ()) page) ) ]
