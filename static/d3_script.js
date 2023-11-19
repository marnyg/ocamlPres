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

    var x = d3.scaleBand().rangeRound([0, width]).padding(0.1);
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
