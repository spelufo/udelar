// var w = 960,
//     h = 500,
//     r = 6,
//     fill = d3.scale.category20();

// var force = d3.layout.force()
//     .charge(-120)
//     .linkDistance(30)
//     .size([w, h]);

var data = d3.json('/previas/ingenieria-22-8.json', function (err, data) {
	var svg = d3.select('svg#canvas')
		.attr('width', svgw = 1200)
		.attr('height', svgh = 700)

	var asig = svg.selectAll('circle')
		.data(data)
		.enter()
		.append('g')
		.attr('transform', function(d){
			return "translate(30," + (Math.floor(Math.random()*svgh/30)*30 + 15) + ")"
		})

	var circle = asig.append('circle')
		.attr('r', 4)

	var labels = asig.append('text')
		.attr('dx', 20)
		.text(function (d) {
		  return d.id + ' - ' + d.nombre
		})
  
	// var link = svg.selectAll("line")
	// 	.data(json.links)
	// 	.enter().append("svg:line");

	// var node = svg.selectAll("circle")
	// 	.data(json.nodes)
	// 	.enter().append("svg:circle")
	// 	.attr("r", r - .75)
	// 	.style("fill", function(d) { return fill(d.group); })
	// 	.style("stroke", function(d) { return d3.rgb(fill(d.group)).darker(); })
	// 	.call(force.drag);

	// force
	// 	.nodes(json.nodes)
	// 	.links(json.links)
	// 	.on("tick", tick)
	// 	.start();

	// function tick(e) {

	// 	// Push sources up and targets down to form a weak tree.
	// 	var k = 6 * e.alpha
	// 	json.links.forEach(function(d, i) {
	// 		d.source.y -= k
	// 		d.target.y += k
	// 	})

	// 	node.attr("cx", function(d) { return d.x; })
	// 		.attr("cy", function(d) { return d.y; });

	// 	link.attr("x1", function(d) { return d.source.x; })
	// 		.attr("y1", function(d) { return d.source.y; })
	// 		.attr("x2", function(d) { return d.target.x; })
	// 		.attr("y2", function(d) { return d.target.y; });
	// }
})



