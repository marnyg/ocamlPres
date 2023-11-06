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
  section [
    div ~a:[a_id "d3-chart"] []; (* Placeholder for the D3 chart *)
    button ~a:[a_onclick "triggerD3Animation();"] [txt "Animate Chart"];
    script ( txt "
      var y; // Define y at a higher scope level to be accessible by both functions
      function triggerD3Animation() {
        // Select all bars and apply a transition
        d3.selectAll('.bar')
          .transition()
          .duration(750)
          .attr('y', function(d) { return y(d.value) - 10; }) // Small bounce effect
          .attr('height', function(d) { return height - y(d.value) + 10; })
          .transition()
          .duration(750)
          .attr('y', function(d) { return y(d.value); }) // Return to original position
          .attr('height', function(d) { return height - y(d.value); });
      }
      
      function createD3Chart() {
        // Simple D3.js bar chart example
        var data = [{label: 'A', value: 30}, {label: 'B', value: 80}, {label: 'C', value: 45}];
        
        var svg = d3.select('#d3-chart').append('svg')
          .attr('width', 400)
          .attr('height', 300);

        var margin = {top: 20, right: 20, bottom: 30, left: 40},
            width = +svg.attr('width') - margin.left - margin.right,
            height = +svg.attr('height') - margin.top - margin.bottom;

        var x = d3.scaleBand().rangeRound([0, width]).padding(0.1)
        y = d3.scaleLinear().rangeRound([height, 0]);

        var g = svg.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

        x.domain(data.map(function(d) { return d.label; }));
        y.domain([0, d3.max(data, function(d) { return d.value; })]);

        g.append('g')
          .attr('class', 'axis axis--x')
          .attr('transform', 'translate(0,' + height + ')')
          .call(d3.axisBottom(x));

        g.append('g')
          .attr('class', 'axis axis--y')
          .call(d3.axisLeft(y).ticks(10, '%'))
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('y', 6)
          .attr('dy', '0.71em')
          .attr('text-anchor', 'end')
          .text('Value');

        g.selectAll('.bar')
          .data(data)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('x', function(d) { return x(d.label); })
          .attr('y', function(d) { return y(d.value); })
          .attr('width', x.bandwidth())
          .attr('height', function(d) { return height - y(d.value); });
      }

      document.addEventListener('DOMContentLoaded', function() {
        createD3Chart();
        Reveal.addEventListener('slidechanged', function(event) {
          if (event.currentSlide.getAttribute('data-state') === 'd3-slide') {
            createD3Chart();
          }
        });
      });
    "
    )
  ]

let get_slides_content =
  let open Html in
  div ~a:[a_class ["slides"]] [
    section [h1 [txt "TyXML"]]
    ; section [p [txt "Is cool!"]]
    ; get_d3_slide
    ; section [form
                 ~a:[a_method `Post; a_action "/feedback"]
                 [ label ~a:[a_label_for "what-you-think"] [txt "Tell us what you think!"]
                 ; input ~a:[a_name "what-you-think"; a_id "what-you-think"] ()
                 ; input ~a:[a_input_type `Submit; a_value "Send"] () ]]
  ]

let get_body =
  let open Html in
  body [div ~a:[a_class ["reveal"]] [
      get_slides_content
      ; script (txt "
        document.addEventListener('DOMContentLoaded', function() {
          Reveal.initialize({ });
        });
      ")
  ]]

let page =
  let open Html in
  html get_head get_body

let () =
  write_html_to_file "index.html" page ;
  Dream.run @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun _ ->
             Dream.respond ~headers:[("Content-Type", "text/html")] (Format.asprintf "%a" (Tyxml.Html.pp ()) page) ) ]
