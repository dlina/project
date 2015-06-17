xquery version "3.0";
declare namespace lina="http://lina.digital";
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
            <xsl:template match="lina:date[not(@when)][text()]">
                <xsl:element name="date" namespace="http://lina.digital">
                    <xsl:attribute name="when" select="if (string-length(.) gt 4) then '0000' else string(.)"/>
                    <xsl:attribute name="type" select="@type"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:template>
            <xsl:template match="lina:date[not(@when)][not(text())]"/>
        </xsl:stylesheet>

let $final := transform:transform($input, $xsl, ()) 
let $valid := validation:jing($final[3], util:binary-doc('/db/apps/lina/resources/lina.rnc') )
let $date :=  if ($final//lina:date[@type='print']/@when and $final//lina:date[@type='premiere']/@when) then min(number($final//lina:date[@type='print']/@when), number($final//lina:date[@type='premiere']/@when)) else if (number($final//lina:date[@type='premiere']/@when)) then $final//lina:date[@type='premiere']/@when else number($final//lina:date[@type='print']/@when),
$date := if ($date - 10 gt number($final//lina:date[@type='written']/@when)) then number($final//lina:date[@type='written']/@when) else $date
let $title := $final//lina:author[1]/string()|| ' ' ||  $final//lina:title[last()]/string() || ' (' ||  $date || ')'
let $filename :=  replace(replace(replace(replace(replace($final//lina:author[1]/substring(.,0,8) || '-' || $final//lina:title[last()]/substring(.,0,8) || '-' || $final//lina:date[1]/@when, '[^\p{L}0-9\-]+', '_'), 'ü', 'ue'), 'ö', 'oe'), 'ä', 'ae'), 'ß', 'ss')
let $login:= xmldb:login($collection, 'TODO', 'TODO')
let $num := format-number(count(file:directory-list('/home/mgoebel/dlina.github.io/networks/_posts/', '*network*.md')//file:file) + 1, '0000')
let $dlina-id := string(year-from-date(current-date())) ||'-'||string(month-from-date(current-date())) ||'-'|| string(day-from-date(current-date())) ||'-network' || $num || '.md'
let $matrix-id := string(year-from-date(current-date())) ||'-'||string(month-from-date(current-date())) ||'-'|| string(day-from-date(current-date())) ||'-matrix' || $num || '.md'
let $entry-id := string(year-from-date(current-date())) ||'-'||string(month-from-date(current-date())) ||'-'|| string(day-from-date(current-date())) ||'-' || $num || '.md'

let $post2 :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category: Matrix
tags: [matrix]
imagefeature: 
mathjax: 
chart: 
comments: false
featured: false
list: false
networkdata: ' || $filename ||'.json
---
{% include matrix.html %}
'

let $post :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags: 
imagefeature: 
mathjax: 
chart: 
comments: false
featured: false
list: false
networkdata: ' || $filename ||'.json
---
{% include network.html %}
{% include network-static.html %}
<div class="row">
  <div class="small-5 small-centered columns"><a href="/matrix'|| $num ||'"><h1>follow me to the matrix</h1></a>
</div>
</div>
'

let $table := string-join(for $value in $final//lina:header/lina:* 
        return 
            $value/name() || 
                    (if ($value/attribute::lina:*) 
                    then string-join(for $attr in $value/@* return ('['|| name($attr) || '="'|| string($attr) || '"]')) 
                    else '')
                    || '|' || $value/string() || '
')

let $ep :=
'---
layout: post
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags:
imagefeature: 
mathjax: 
chart: 
comments: true
featured: false
list: false
networkdata: ' || $filename ||'.json
---
lina.xml data  | value
------------- | -------------
' || $table || '

* [Network (sticky and static)](/network'|| $num ||')
* [Matrix](/matrix' || $num || ')
'

let $request := 
<http:request method="get" http-version="1.0" href="http://localhost/exist/rest/db/apps/lina/getjson.xql?f={$filename}.xml"></http:request>

(: make sure you use the right user permissions that has write access to this collection :)
let $store := if ($valid) 
                then 
                    (
                        xmldb:store($collection, $filename || '.xml', $final[3]),
                        xmldb:store('/db/data/lina/uploads/untouched', $filename || '.xml', $input),
                        xmldb:store('/db/data/lina/sync/data', $filename || '.json', string-join(http:send-request($request)), 'application/json' ),
                        file:sync('/db/data/lina/sync/data', '/home/mgoebel/dlina.github.io/data/', ()),
                        file:serialize-binary(xs:base64Binary(util:base64-encode($post)), '/home/mgoebel/dlina.github.io/networks/_posts/'|| $dlina-id),
                        file:serialize-binary(xs:base64Binary(util:base64-encode($post2)), '/home/mgoebel/dlina.github.io/networks/_posts/'|| $matrix-id),
                        file:serialize-binary(xs:base64Binary(util:base64-encode($ep)), '/home/mgoebel/dlina.github.io/networks/_posts/'|| $entry-id)

                    )
                else 'I am sorry but there was nothing stored in the database. Propably the file you tried to upload is not valid. See above for any message.'
return
    if ($valid) then

    <html>
        <head>
            <meta http-equiv="refresh" content="10; http://dlina.github.io/network{$num || '/'}"/>
        </head>
        <body>
            <results>
                <div>   
                <p>Validation against lina.rnc powered by JING returned: YEAH! </p>
                </div>
                <p>File {$filename} stored at collection={$collection} stored.</p>
                <a href="view.html?f={$filename}">View the network</a> or wait 10 seconds for redirection to dlina.github.io.
            </results>
        </body>
    </html>
    
    else
            <html>
        <head>
            <title> validation error </title>
        </head>
        <body>
            <results>
                <div>
                <p>Validation against lina.rnc powered by JING returned: <a href="http://en.wikipedia.org/wiki/D%27oh!">D'oh!</a></p>
                <p>JING report:</p>
                <pre><code>{validation:jing-report($final[3], util:binary-doc('/db/apps/lina/resources/lina.rnc'))}</code></pre>
                </div>
                <p>File {$filename} not stored at collection={$collection}. Please review the file.</p>
            </results>
        </body>
    </html>
