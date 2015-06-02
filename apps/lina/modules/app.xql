xquery version "3.0";
module namespace app="lina.digital/templates";

declare namespace lina="http://lina.digital";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="lina.digital/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated). 
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 
declare function app:switch($node as node(), $model as map(*)) {
<form        enctype="multipart/form-data"
 method="post" action="upload2.xql">
    <fieldset>
        <legend>Upload Zwischenformat:</legend>
        <input type="file" name="f"  accept="text/xml"/>
        <input type="submit" value="Upload"/>
    </fieldset>
</form>
};

declare function app:view($node as node(), $model as map(*)){
let $f := request:get-parameter('f', 'latest')
let $f := if ($f = 'latest') 
            then
                let $map:=  for $res in xmldb:get-child-resources('/db/data/lina/uploads')
                            order by xmldb:last-modified('/db/data/lina/uploads', $res) descending
                            return ($res, xmldb:last-modified('/db/data/lina/uploads', $res))
                return $map[1]        
            else $f
return
(<div id="network"/>,
<script>
 <![CDATA[
                
var width = 960,
    height = 800;

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge(-200)
    .linkDistance(190)
    .size([width, height]);

var svg = d3.select("#network").append("svg")
    .attr("width", width)
    .attr("height", height);

d3.json("getjson.xql?f=]]>{$f}<![CDATA[", function(error, graph) {
  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();
  var link = svg.selectAll(".link")
      .data(graph.links)
    .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });

  var gnodes = svg.selectAll('g.gnode')
     .data(graph.nodes)
     .enter()
     .append('g')
     .classed('gnode', true);
    
  var node = gnodes.append("circle")
      .attr("class", "node")
      .attr("r", function(d) { return Math.sqrt(d.weight) + 5 })
      .style("fill", function(d) { return color(d.group); })
      .call(force.drag);

  var labels = gnodes.append("text")
      .text(function(d) { return d.name; });

  console.log(labels);
    
  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    gnodes.attr("transform", function(d) { 
        return 'translate(' + [d.x, d.y] + ')'; 
    });
      
    
      
  });
});

drawGraph(graph);

                    ]]>
</script>)

};

declare function app:matrix($node as node(), $model as map(*)){
let $f := request:get-parameter('f', 'latest')
let $f := if ($f = 'latest') 
            then
                let $map:=  for $res in xmldb:get-child-resources('/db/data/lina/uploads')
                            order by xmldb:last-modified('/db/data/lina/uploads', $res) descending
                            return ($res, xmldb:last-modified('/db/data/lina/uploads', $res))
                return $map[1]        
            else $f
return
(<div id="matrix"/>,
<p>Order: <select id="order">
  <option value="name">by Name</option>
  <option value="count">by Frequency</option>
  <option value="group">by Cluster</option>
</select>
</p>,
<script>
<![CDATA[
var margin = {top: 150, right: 0, bottom: 10, left: 150},
    width = 600,
    height = 600;
var x = d3.scale.ordinal().rangeBands([0, width]),
    z = d3.scale.linear().domain([0, 4]).clamp(true),
    c = d3.scale.category10().domain(d3.range(10));

var svg = d3.select("#matrix").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .style("margin-left", -margin.left + "px")
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.json("getjson.xql?f=]]>{$f}<![CDATA[", function(graph) {
  var matrix = [],
      nodes = graph.nodes,
      n = nodes.length;

  // Compute index per node.
  nodes.forEach(function(node, i) {
    node.index = i;
    node.count = 0;
    matrix[i] = d3.range(n).map(function(j) { return {x: j, y: i, z: 0}; });
  });

  // Convert links to matrix; count character occurrences.
  graph.links.forEach(function(link) {
    matrix[link.source][link.target].z += link.value;
    matrix[link.target][link.source].z += link.value;
    matrix[link.source][link.source].z += link.value;
    matrix[link.target][link.target].z += link.value;
    nodes[link.source].count += link.value;
    nodes[link.target].count += link.value;
  });

  // Precompute the orders.
  var orders = {
    name: d3.range(n).sort(function(a, b) { return d3.ascending(nodes[a].name, nodes[b].name); }),
    count: d3.range(n).sort(function(a, b) { return nodes[b].count - nodes[a].count; }),
    group: d3.range(n).sort(function(a, b) { return nodes[b].group - nodes[a].group; })
  };

  // The default sort order.
  x.domain(orders.name);

  svg.append("rect")
      .attr("class", "background")
      .attr("width", width)
      .attr("height", height);

  var row = svg.selectAll(".row")
      .data(matrix)
    .enter().append("g")
      .attr("class", "row")
      .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .each(row);

  row.append("line")
      .attr("x2", width);

  row.append("text")
      .attr("x", -6)
      .attr("y", x.rangeBand() / 2)
      .attr("dy", ".32em")
      .attr("text-anchor", "end")
      .text(function(d, i) { return nodes[i].name; });

  var column = svg.selectAll(".column")
      .data(matrix)
    .enter().append("g")
      .attr("class", "column")
      .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });

  column.append("line")
      .attr("x1", -width);

  column.append("text")
      .attr("x", 6)
      .attr("y", x.rangeBand() / 2)
      .attr("dy", ".32em")
      .attr("text-anchor", "start")
      .text(function(d, i) { return nodes[i].name; });

  function row(row) {
    var cell = d3.select(this).selectAll(".cell")
        .data(row.filter(function(d) { return d.z; }))
      .enter().append("rect")
        .attr("class", "cell")
        .attr("x", function(d) { return x(d.x); })
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill-opacity", function(d) { return z(d.z); })
        .style("fill", function(d) { return nodes[d.x].group == nodes[d.y].group ? c(nodes[d.x].group) : null; })
        .on("mouseover", mouseover)
        .on("mouseout", mouseout);
  }

  function mouseover(p) {
    d3.selectAll(".row text").classed("active", function(d, i) { return i == p.y; });
    d3.selectAll(".column text").classed("active", function(d, i) { return i == p.x; });
  }

  function mouseout() {
    d3.selectAll("text").classed("active", false);
  }

  d3.select("#order").on("change", function() {
    clearTimeout(timeout);
    order(this.value);
  });

  function order(value) {
    x.domain(orders[value]);

    var t = svg.transition().duration(2500);

    t.selectAll(".row")
        .delay(function(d, i) { return x(i) * 4; })
        .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .selectAll(".cell")
        .delay(function(d) { return x(d.x) * 4; })
        .attr("x", function(d) { return x(d.x); });

    t.selectAll(".column")
        .delay(function(d, i) { return x(i) * 4; })
        .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });
  }

  var timeout = setTimeout(function() {
    order("group");
    d3.select("#order").property("selectedIndex", 2).node().focus();
  }, 5000);
});
]]>
</script>)
};