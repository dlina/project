xquery version "3.0";
module namespace animation="http://lina.digital/animation";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare namespace lina="http://lina.digital";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";
declare option output:media-type "text/plain";

declare variable $animation:timing as xs:integer := 5000;
declare variable $animation:varnames:= for $a in (string-to-codepoints('a') to string-to-codepoints('z')) return
                                for $b in (string-to-codepoints('a') to string-to-codepoints('z')) return
                                    codepoints-to-string($a)||codepoints-to-string($b);

declare function local:who($position as xs:integer, $play) as xs:string*{
    distinct-values(
        (for $i in ($play//lina:div[lina:sp])[$position]/lina:sp/tokenize(string(@who), ' ')
        return substring-after($i, '#')
        ))
};

declare function local:vars($position as xs:integer,$play, $map, $mapid){
let $seq := for $who in local:who($position, $play) let $result := $map($who) order by $result return $result
let $seq0 := for $who in local:who($position - 1, $play) let $result := $map($who) order by $result return $result
let $union:= ($seq, $seq0)
let $duplicates :=  for $d in $union[index-of($union, .)[2]] order by $d return $d
return 
    for $item at $pos in $seq
    return
        if(exists( index-of($seq0, $item) )) 
        then
            $item||" = nodes[" || index-of($duplicates, $item) -1|| "]"
        else
            $item||" = {id: '"||$item||"', name:'"|| $mapid($item) ||"'}"
};
declare function local:varsClean($position as xs:integer, $play, $map, $mapid){
let $seq := for $who in local:who($position, $play) let $result := $map($who) order by $result return $result
let $seq0 := for $who in local:who($position - 1, $play) let $result := $map($who) order by $result return $result
let $union:= ($seq, $seq0)
let $duplicates :=  for $d in distinct-values($seq0) where not( exists( ($union[. = $d])[2] ) ) return $d
return 
    $duplicates
};
declare function local:pushNodes($position as xs:integer,$play, $map, $mapid){
let $who1 := local:who($position, $play),
    $who0 := local:who($position -1, $play),
    $who0Vars := distinct-values($who0 ! $map(.)),
    $who1Vars := distinct-values($who1 ! $map(.))

return
    (: do not push nodes already in array :)
    for $var in $who1Vars 
    where not($who0Vars[. = $var]) 
    order by $var
    return $var
};

declare function local:pushLinks($position as xs:integer, $play, $map, $mapid){
    for $item1 in local:who($position, $play) let $i1 := $map($item1) return
        for $item2 in local:who($position, $play)
        let $i2 := $map($item2)
        where $i2 gt $i1
        return
            "{source: "|| $i1 ||" , target: " || $i2 || " }"
};

declare function local:div($position as xs:integer, $play, $map, $mapid){
    let $var := string-join( local:vars($position, $play, $map, $mapid), ',')
    let $nodes.push :=  if(matches($var, '\{')) then ("nodes.push(", string-join( distinct-values(local:pushNodes($position, $play, $map, $mapid)), ','),");")
                        else "/* nodes.push(); */"
    return
("setTimeout(function() {","console.log('load"||$position||"');",
"var ", $var,";",
$nodes.push,
"links.push(", string-join( local:pushLinks($position, $play, $map, $mapid), ','),");",
"start();",
"var SomethingBeforeAnAct = document.getElementById('SomethingBeforeAnAct');SomethingBeforeAnAct.innerHTML = '"|| ($play//lina:div[lina:sp])[$position]/parent::lina:div/parent::lina:div/lina:head/text() ||"';",
"var act = document.getElementById('act');act.innerHTML = '"|| ($play//lina:div[lina:sp])[$position]/parent::lina:div/lina:head/text() ||"';",
"var scene = document.getElementById('scene');scene.innerHTML = '"|| ($play//lina:div[lina:sp])[$position]/lina:head/text() ||"';
}, "|| ($position - 1) * $animation:timing ||");
")
};

declare function local:cleanup($position as xs:integer, $play, $map, $mapid){
let $old := for $item in local:who($position, $play) return $map($item)
let $new := for $item in local:who($position + 1, $play) return $map($item)

let $vars := for $item in $old where not( exists( index-of( $new, $item ) ) ) return "'"||$item||"'"
let $vars := distinct-values($vars)
return (
        "setTimeout(function() {","console.log('remv"||$position||"');",
        "var rm = [", string-join( $vars, "," ), "];",
        "rmNodes(rm);",
        "rmLinks(rm);",
        "start(); }, " || ($position) * $animation:timing - ($animation:timing div 4) || ");
"
)
};
declare function animation:start($play as element(lina:play)){

let $map := map:new( for $character at $pos in $play//lina:personae/lina:character return 
                                    for $id in $character//lina:alias[@xml:id]/string(@xml:id) return map:entry($id, $animation:varnames[$pos]) )
let $mapid := map:new( for $character at $pos in $play//lina:personae/lina:character return 
                                    for $id in $character//lina:alias[@xml:id]/string(@xml:id) return map:entry($animation:varnames[$pos], $id) )

let $count := count( $play//lina:div[lina:sp] )
return
(

(:"document.getElementById('title').innerHTML = '" || $play/lina:header/lina:title/text() || "';:)
(:",:)


for $n in (1 to $count - 1) return
(string-join(local:div($n, $play, $map, $mapid), ' '), string-join(local:cleanup($n, $play, $map, $mapid), ' '))
,
string-join(local:div($count, $play, $map, $mapid), ' ')
)
};