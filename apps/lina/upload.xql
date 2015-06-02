xquery version "3.0";
declare namespace lina="http://lina.digital";

let $collection := '/db/data/lina/uploads/'
let $filename := if (request:get-uploaded-file-name('file'))
                    then request:get-uploaded-file-name('file')
                    else if (request:get-parameter('filename', '')) then request:get-parameter('filename', '')
                    else ''

return
    if ($filename != '') then
let $login := xmldb:login($collection, 'lina', 'linadigitäl690?')
let $doc :=   util:parse(util:base64-decode(string(request:get-uploaded-file-data('file'))))
let $xsl:=
        <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lina="http://lina.digital" >
            <xsl:template match="@*|node()">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:template>
            <xsl:template match="lina:sp/@who">
                <xsl:variable name="crt" select="."/>
                <xsl:variable name="alias" select="//@xml:id[ancestor::lina:character//lina:alias[@xml:id = substring-after($crt, '#')]]"/>
                <xsl:choose>
                    <xsl:when test="count($alias) gt 1">
                        <xsl:attribute name="who" select="concat('#', $alias[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="who" select="$crt"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:template>
        </xsl:stylesheet>

let $final := transform:transform($doc, $xsl, ())

let $store := xmldb:store($collection, $filename, $final)

return
                (<div/>,
                <script>
                    <![CDATA[
                
var width = 960,
    height = 500;

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge(-200)
    .linkDistance(190)
    .size([width, height]);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

d3.json("getjson.xql?]]>{$filename}<![CDATA[", function(error, graph) {
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
      .attr("r", 5)
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


else
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>LiNa Upload</title>
    </head>
    <body>
        <form enctype="multipart/form-data" method="post" action="upload.xql">
            <fieldset>
                <legend>Upload Zwischenformat:</legend>
                <input type="file" name="f"/>
                <input type="submit" value="Upload"/>
            </fieldset>
        </form>
        
        <p>You can also have a look on the <a href="upload.xql?latest">latest upload</a>.</p>
    </body>
</html>