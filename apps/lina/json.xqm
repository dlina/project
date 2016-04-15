xquery version "3.0";
module namespace json="http://lina.digital/json";
declare namespace  lina="http://lina.digital";

declare function json:json($lina as element(lina:play)){
let $names :=  for $name in $lina//lina:character
                return
                    '{"name":"' || $name/lina:name/string() ||
                    '","group":'  || (switch (($name//lina:sex/string())[1]) 
                                                case "male" return '1'
                                                case "female" return '3'
                                                case "M" return "1"
                                                case "F" return "3"
                                                default return "5")  ||
                    ', "weight":100},'

let $names := string-join($names[position() lt last()], '&#10;') || '&#10;' || substring-before($names[last()], '},') || '}'
let $index := $lina//lina:character/lina:alias[1]/lower-case(@xml:id)
let $links :=
        
            for $div in $lina//lina:div[lina:sp] 
            return
                for $source at $pos1 in $div//lina:sp/lower-case( substring-after(@who, '#') )
                where $source != ''
                return
                    for $target at $pos2 in $div//lina:sp/lower-case( substring-after(@who, '#') )
                    let $isource := index-of($index, $source)
                    let $itarget := index-of($index, $target)
                    where $pos2 gt $pos1 and $target != ''
                    return
                        '{"source":' || (if(string($isource) = '') then $source else $isource - 1) ||
                        ',"target":' || (if(string($itarget) = '') then $target else $itarget - 1) ||
                        ',"value":' || 3 || '},'

let $distinctlinks := distinct-values( $links )
let $distinctlinkswithweight := for $link in $distinctlinks
                                    let $count := count( $links[.=$link] )
                                    let $replacement :=  'value:'||string($count)
                                    return
                                        replace($link, 'value:\d', $replacement)
   
(:            for $source in $lina//lina:alias/lower-case(@xml:id):)
(:            let $targets := $lina//lina:sp[preceding-sibling::lina:sp]/@who:)
(:            return:)
(:                for $target in ( :)
(:                                for $sp in $lina//lina:sp[:)
(:                                        contains(@who, '#' || $source):)
(:                                        or contains(preceding-sibling::lina:sp/@who, ('#' || $source)):)
(:                                        or contains(following-sibling::lina:sp/@who, ('#' || $source))]:)
(:                                return tokenize(string($sp/@who), ' '):)
(:                                ):)
(:                where index-of($index, substring-after($target, '#')) gt index-of($index, $source):)
(:                return:)
(:                let $value := count($lina//lina:div[child::lina:sp/contains(@who, $target)][child::lina:sp/contains(@who, ('#' || $source))]):)
(:                return:)
(:                   '{"source":' || index-of($index, $source) - 1 ||:)
(:                   ',"target":' || index-of($index, substring-after($target, '#')) -1  ||:)
(:                   ',"value":' || $value * $value || '},':)
let $newlinks:=  string-join($distinctlinkswithweight[position() lt last()], '&#10;') || '&#10;' || substring-before($links[last()], '},') || '}'

return
'{
"nodes":[
'||$names||'
],
"links":[
'||$newlinks||'
]
}'

};

