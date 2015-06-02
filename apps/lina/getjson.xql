xquery version "3.0";
declare namespace lina="http://lina.digital";
declare option exist:serialize "method=text media-type=text/plain";

let $filename := request:get-parameter('f', 'macbeth.xml')
let $doc := doc('/db/data/lina/uploads/' ||  $filename )
let $names :=  for $name in $doc//lina:character
                return
                    '{"name":"' || $name/lina:name/string() ||
                    '","group":'  || (switch (($name//lina:sex/string())[1]) 
                                                case "male" return '1'
                                                case "female" return '3'
                                                default return "5")  ||
                    ', "weight":100},'

let $names := string-join($names[position() lt last()], '&#10;') || '&#10;' || substring-before($names[last()], '},') || '}'
let $index := $doc//lina:character/lina:alias[1]/lower-case(@xml:id)
let $links := 
            for $source in $doc//lina:alias/lower-case(@xml:id)
            let $targets := $doc//lina:sp[preceding-sibling::lina:sp]/@who
            return
                for $target in (
                                for $sp in $doc//lina:sp[
                                        contains(@who, '#' || $source)
                                        or contains(preceding-sibling::lina:sp/@who, ('#' || $source))
                                        or contains(following-sibling::lina:sp/@who, ('#' || $source))]
                                return tokenize(string($sp/@who), ' ')
                                )
                where index-of($index, substring-after($target, '#')) gt index-of($index, $source)
                return
                let $value := count($doc//lina:div[child::lina:sp/contains(@who, $target)][child::lina:sp/contains(@who, ('#' || $source))])
                return
                   '{"source":' || index-of($index, $source) - 1 ||
                   ',"target":' || index-of($index, substring-after($target, '#')) -1  ||
                   ',"value":' || $value * $value || '},'
let $links:=  string-join($links[position() lt last()], '&#10;') || '&#10;' || substring-before($links[last()], '},') || '}'

return
'{
"nodes":[
'||$names||'
],
"links":[
'||$links||'
]
}'