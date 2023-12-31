open Tyxml

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
