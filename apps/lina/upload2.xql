xquery version "3.0";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace git="http://exist-db.org/git";

declare option exist:serialize "method=html5 media-type=text/html omit-xml-declaration=yes indent=yes";
let $collection := '/db/data/lina/uploads/'
let $filename := request:get-uploaded-file-name('f')

let $input := util:parse(util:base64-decode(xs:string(  request:get-uploaded-file-data('f') )))
let $test :=( console:log(request:get-remote-addr()), console:log($input)  )           
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

let $final := transform:transform($input, $xsl, ()) 
let $valid := validation:jing($final[1], util:binary-doc('/db/apps/lina/resources/lina.rnc'))

let $post :=
'---
layout: post
title: "Data"
author: frank
description:
headline:
modified:
category: Networks
tags: [network]
imagefeature: 
mathjax: 
chart: 
comments: true
featured: false
--- 
<div id="network"/>
<script>
                
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

d3.json("/data/' || substring-before($filename, 'xml') || '.json", function(error, graph) {
  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();
  var link = svg.selectAll(".link")
      .data(graph.links)
    .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });

  var gnodes = svg.selectAll(&#39;g.gnode&#39;)
     .data(graph.nodes)
     .enter()
     .append(&#39;g&#39;)
     .classed(&#39;gnode&#39;, true);
    
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
        return &#39;translate(&#39; + [d.x, d.y] + &#39;)&#39;;
    });
  })
});
drawGraph(graph);
</script>'

(: make sure you use the right user permissions that has write access to this collection :)
let $login:= xmldb:login($collection, 'admin', 'SADE#?TextGrid')
let $netnum := format-number(
                    count(  for $item in xmldb:get-child-resources( '/db/apps/lina/git/data')
                            where starts-with($item, 'network-')
                            return $item
                        ),
                    '0000' )
let $store := if ($valid) 
                then 
                    (
                        xmldb:store($collection, $filename, if ($final[2]) then $final[1] else $final[1]),
                        xmldb:store('/db/apps/lina/git/data', substring-before($filename, 'xml') || 'json', xmldb:decode(httpclient:get(xs:anyURI('http://localhost/exist/rest/db/apps/lina/getjson.xql?f=test3.xml'), true(), ())//httpclient:body/string()), 'application/json' ),
                        xmldb:store('/db/apps/lina/git/_posts', 'network-' || $netnum || '.md' , $post, 'text/plain'),
                        git:add('/db/apps/lina/git/', ('data/' || substring-before($filename, 'xml') || 'json', '_posts/network-' || $netnum || '.md')),
                        git:commit('/db/apps/lina/git', 'added new JSON data for ' || $filename),
                        git:push('/db/apps/lina/git', 'DLiNa', 'linadigitäl690?')
                    )
                else 'I am sorry but there was nothing saved in the database. Propably the file you tried to upload is not valid. See above for any message.'
return
    if ($valid) then

    <html>
        <head>
            <meta http-equiv="refresh" content="5; view.html?f={$filename}"/>
        </head>
        <body>
            <results>
                <div>   
                <p>Validation against lina.rnc powered by JING returned: YEAH! </p>
                </div>
                <p>File {$filename} stored at collection={$collection} stored.</p>
                <a href="view.html?f={$filename}">View the network</a> or wait 5 seconds for redirection.
            </results>
        </body>
    </html>
    
    else
            <html>
        <head>
            
        </head>
        <body>
            <results>
                <div>
                <p>Validation against lina.rnc powered by JING returned: <a href="http://en.wikipedia.org/wiki/D%27oh!">D'oh!</a></p>
                <p>JING report:</p>
                <pre><code>{validation:jing-report($final[1], util:binary-doc('/db/apps/lina/resources/lina.rnc'))}</code></pre>
                </div>
                <p>File {$filename} not stored at collection={$collection}. Please review the file.</p>
            </results>
        </body>
    </html>
    