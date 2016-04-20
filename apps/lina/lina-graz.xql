xquery version "3.0";
declare namespace  lina="http://lina.digital";

import module namespace console="http://exist-db.org/xquery/console";
import module namespace json="http://lina.digital/json" at "/db/apps/lina/json.xqm";
import module namespace animation="http://lina.digital/animation" at "/db/apps/lina/modules/animation.xqm";

declare function local:cleanup($path, $task){
if( xmldb:collection-available($path || '/' || $task) )
then let $do := (xmldb:remove($path || '/' || $task),xmldb:create-collection($path, $task) ) return 
    true()
else let $do := xmldb:create-collection($path, $task) return true()
};
(: Asuming you have the module for the preparation of json files and hte recent lina.xml 
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
 : see ids.csv for a complete list 
 : OR use the crawler :)
let $offset := 0
let $what := ('json' ,'lina','matrix' ,'entry','network','amount','animation' )
let $path := '/db/apps/lina/data'
(: pattern is used to replace characters in author names :)
let $pattern := '[^a-zA-Z0-9:,\s]'
let $dlina-ids := ("Horvath: Gesamtfassung", 'Horvath: Endfassung')

(: TEST with a single item :)
(:  let $dlina-ids := ("Lessing, Gotthold Ephraim: Emilia Galotti"):)

(: CLEAN UP! :)
let $cleanup :=
    for $task in $what
    return
        local:cleanup($path, $task)

let $col := collection($path||'/source')

return
    for $lina in $col//lina:play
    let $num := number( substring-before( tokenize( $lina/base-uri(), '/' )[matches(., 'xml')], '.' )) + $offset,
        $console := console:log($num)
    return
    
(:    let $console := console:log(index-of($dlina-ids, $id)):)
(:    return:)
(:        for $lina in $col/lina:play//lina:header[concat(lina:author/replace(., $pattern, ''), ': ', lina:title/replace(., $pattern, '') ) = $id]:)

let $date := 
if ($lina//lina:date[@type='print']/@when and $lina//lina:date[@type='premiere']/@when) then min(number($lina//lina:date[@type='print']/@when), number($lina//lina:date[@type='premiere']/@when)) else if (number($lina//lina:date[@type='premiere']/@when)) then $lina//lina:date[@type='premiere']/@when else number($lina//lina:date[@type='print']/@when),
$date := if ($date - 10 gt number($lina//lina:date[@type='written']/@when)) then number($lina//lina:date[@type='written']/@when) else $date
   
let $title := $lina//lina:author[1]/string()|| ': ' ||  $lina//lina:title[last()]/string() || ' (' ||  $date || ')',
$blogdate := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date())
(: lina file with xml source :)

let
$filenamexml := $blogdate || '-lina' || $num || '.md'
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
serialize( $lina ) ||'
{% endhighlight %}' 

(: THE MATRIX :)
let
$filenamematrix := $blogdate || '-matrix' || $num || '.md',
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
$filenamenetwork := $blogdate || '-network' || $num || '.md',
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
    $linafilejson:= json:json( $lina )

(: ENTRY POINT :)
let
    $filenameentry := $blogdate || '-' || $num || '.md' ,
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
* [Animation](/animation'|| $num ||' )
'

(: AMOUNTS :)

let
$filenamebarchart := $blogdate || '-' || 'amount' || $num || '.md',
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

(: ANIMATION :)
let $filenameanimation := $blogdate || '-animation' || $num || '.md'
let $linafileanimation :=
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
networkdata: animation' || $num ||'.js
---
{% include animation.html %}
'
let $animatonscript := string-join(animation:start($lina), '&#10;')
let $filenameanimationJs := 'animation' || $num || '.js'  

return 
for $task in $what
    return
        switch($task)
        case 'animation' return (   xmldb:store($path||'/animation', $filenameanimation, $linafileanimation, 'text/plain'),
                                    xmldb:store($path||'/animation', $filenameanimationJs, $animatonscript, 'text/javascript') )
        case 'json'     return xmldb:store($path||'/json', $filenamejson, $linafilejson, 'text/plain')
        case 'lina'     return xmldb:store($path||'/lina', $filenamexml, $linafilexml, 'text/plain')
        case 'matrix'   return xmldb:store($path||'/matrix', $filenamematrix, $linafilematrix, 'text/plain')
        case 'entry'    return xmldb:store($path||'/entry', $filenameentry, $linafileentry, 'text/plain')
        case 'network'  return xmldb:store($path||'/network', $filenamenetwork, $linafilenetwork, 'text/plain')
        case 'amount'   return (xmldb:store($path||'/amount', $filenamebarchart, $linafilebarchart, 'text/plain'),xmldb:store($path||'/amount', $filenametsv, $linafiletsv, 'text/plain') )
        default return 'one round for free'