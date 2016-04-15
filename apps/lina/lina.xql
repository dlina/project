xquery version "3.0";
declare namespace  lina="http://lina.digital";

(:import module namespace console="http://exist-db.org/xquery/console";:)
import module namespace json="http://lina.digital/json" at "/db/apps/lina/json.xqm";

(: Asuming you have the module for the preparation of json files and the recent lina.xml 
 : files in a folder like described by variable $col, you can prepare ALL markdown and
 : data files needed for the incredible dlina website with the help of this XQuery!
 : The first sequence ($dlina-ids) is to prevent the IDs ($num) created when first starting this 
 : program. So we can be sure, that the links are stable. We needed to hardcode them once.
 : For the lazy ones: Just add one of the following tasks in lower case to the sequence $what
 : 
 : TEST: test run with a single lina file
 : JSON: creates JSON
 : LINA: creates the syntaxhighlighted XML
 : ENTRY: creates the entry point
 : MATRIX: ok, yo got it
 : NETWORK: again
 : AMOUNT: are you kidding me?
 :   :)

(: offset according the ids before the one you like to create.
 : see ids.csv for a complete list. :)
let $offset := 465
let $what := ('json', 'network', 'matrix', 'entry', 'lina', 'amount')
let $path := '/db/tmp/graz'
(: pattern is used to replace characters in author names :)
let $pattern := '[^a-zA-Z0-9:,\s]'
let $dlina-ids := ("Horvath: Gesamtfassung", 'Horvath: Endfassung')

(: TEST with a single item :)
(:  let $dlina-ids := ("Lessing, Gotthold Ephraim: Emilia Galotti"):)

(: CLEAN UP! :)
let $cleanup := (
    for $task in $what
    return
    if ($task = 'json') then (xmldb:remove($path||'/json'),xmldb:create-collection($path, "json" ))
    else if ($task = 'lina') then (xmldb:remove($path||'/lina'),xmldb:create-collection($path, "lina" ))
    else if ($task = 'matrix') then (xmldb:remove($path||'/matrix'),xmldb:create-collection($path, "matrix" ))
    else if ($task = 'entry') then (xmldb:remove($path||'/entry'),xmldb:create-collection($path, "entry" ))
    else if ($task = 'network') then(xmldb:remove($path||'/network'),xmldb:create-collection($path, "network" ))
    else if ($task = 'amount') then (xmldb:remove($path||'/amount'),xmldb:create-collection($path, "amount") )
    else 'nothing to clean')

let $col := collection($path||'/source')

return
for $id in $dlina-ids
(:    let $console := console:log(index-of($dlina-ids, $id)):)
    return
        for $lina in $col/lina:play//lina:header[concat(lina:author/replace(., $pattern, ''), ': ', lina:title/replace(., $pattern, '') ) = $id]

let $date := 
if ($lina//lina:date[@type='print']/@when and $lina//lina:date[@type='premiere']/@when) then min(number($lina//lina:date[@type='print']/@when), number($lina//lina:date[@type='premiere']/@when)) else if (number($lina//lina:date[@type='premiere']/@when)) then $lina//lina:date[@type='premiere']/@when else number($lina//lina:date[@type='print']/@when),
$date := if ($date - 10 gt number($lina//lina:date[@type='written']/@when)) then number($lina//lina:date[@type='written']/@when) else $date
   
let $title := $lina//lina:author[1]/string()|| ': ' ||  $lina//lina:title[last()]/string() || ' (' ||  $date || ')'
let $num := index-of($dlina-ids, $id) + $offset

(: lina file with xml source :)

let
$filenamexml := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-lina' || $num || '.md'
let 
$linafilexml :=
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
comments: true
featured: false
list: false
---
{% highlight xml %}
'||
serialize(doc( $lina/base-uri() )) ||'
{% endhighlight %}' 

(: THE MATRIX :)
let
$filenamematrix := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-matrix' || $num || '.md',
$linafilematrix :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags: []
imagefeature: 
mathjax: 
chart: 
comments: false
featured: false
list: false
networkdata: ' || $num ||'.json
---
{% include matrix.html %}
'

(: THE NETWORK :)

let
$filenamenetwork := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-network' || $num || '.md',
$linafilenetwork :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags: []
imagefeature: 
mathjax: 
chart: 
comments: false
featured: false
list: false
networkdata: ' || $num ||'.json
---
{% include network.html %}
{% include network-static.html %}
'

(: JSON :)

let
$filenamejson := ($num || '.json'),
$linafilejson:= json:json( doc( $lina/base-uri() )//lina:play )

(: ENTRY POINT :)
let
$filenameentry := ( year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-' || $num || '.md' ),
$table := string-join(
    for $value in $lina/lina:* 
        return 
            $value/name() || 
                    (if ($value/attribute::*) 
                    then string-join(for $attr in $value/@* return ('[@'|| name($attr) || '="'|| string($attr) || '"]')) 
                    else '')
                    || '|' || (if (contains($value, 'textgridlab.org')) then '[' || substring-after(substring-before($value, '/data'), 'tgcrud-public/rest/') || '](' || $value/string() || ')' else $value/string()) || '
'),
$linafileentry :=
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
comments: true
featured: false
list: true
networkdata: ' || $filenamejson ||'
---
lina.xml data  | value
------------- | -------------
' || $table || '


* [Network (sticky and static)](/network'|| $num ||')
* [Matrix](/matrix' || $num || ')
* [Amounts](/amount' || $num || ')
* [Zwischenformat](/lina'|| $num ||' )
'

(: AMOUNTS :)

let
$filenamebarchart := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-' || 'amount' || $num || '.md',
$filenametsv := $num || '.tsv',
$linafilebarchart :=
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
comments: true
featured: false
list: false
amounttsv: ' || $filenametsv ||'
---
{% include barchart.html %}
'

let $tab := '&#9;' (: tab :),
$linafiletsv :=
('name'||$tab||'acts'||$tab||'words'||$tab||'chars'||$tab||'
'||
string-join(for $c in $lina/parent::lina:play//lina:character
return
    ($c//lina:name/string())[1]||$tab||
    sum($lina/parent::lina:play//lina:amount[parent::lina:sp/@who = $c//lina:alias/concat('#', @xml:id)][@unit='speech_acts']/xs:int(@n)) ||$tab||
    sum($lina/parent::lina:play//lina:amount[parent::lina:sp/@who = $c//lina:alias/concat('#', @xml:id)][@unit='words']/xs:int(@n)) ||$tab||
    sum($lina/parent::lina:play//lina:amount[parent::lina:sp/@who = $c//lina:alias/concat('#', @xml:id)][@unit='chars']/xs:int(@n)) ||$tab||'
' )  
)

return 
for $task in $what
    return
    if ($task = 'json') then xmldb:store($path||'/json', $filenamejson, $linafilejson, 'text/plain')
    else if ($task = 'lina') then xmldb:store($path||'/lina', $filenamexml, $linafilexml, 'text/plain')
    else if ($task = 'matrix') then xmldb:store($path||'/matrix', $filenamematrix, $linafilematrix, 'text/plain')
    else if ($task = 'entry') then xmldb:store($path||'/entry', $filenameentry, $linafileentry, 'text/plain')
    else if ($task = 'network') then  xmldb:store($path||'/network', $filenamenetwork, $linafilenetwork, 'text/plain')
    else if ($task = 'amount') then ( xmldb:store($path||'/amount', $filenamebarchart, $linafilebarchart, 'text/plain'),xmldb:store($path||'/amount', $filenametsv, $linafiletsv, 'text/plain') )
    else 'one round for free'

