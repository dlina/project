xquery version "3.0";

let $collection-uri := '/db/apps/lina/data/lina'

let $count := count ((httpclient:get(xs:anyURI('https://dlina.github.io/linas/index.html'), false(), ())//ul)[2]/li)
let $mime-type := 'text/xml'

return
for $i in (1 to $count)
let $resource := $i||'.xml'
let $contents := parse-xml( string-join(httpclient:get(xs:anyURI('https://dlina.github.io/lina'||$i||'/index.html'), false(), ())//code//text()) )//*:play
return
xmldb:store($collection-uri, $resource, $contents, $mime-type)