xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lina="http://lina.digital";
declare default element namespace "http://www.tei-c.org/ns/1.0";

let $collection-uri := '/db/data/'

return
for $name at $pos in xmldb:get-child-resources($collection-uri)
    let $pos := $pos + 1000
    let $doc:= doc('/db/data/'||$name)
    let $lina :=
    <play xmlns="http://lina.digital" id="{$pos}">
      <header>
        <title>{$doc//tei:titleStmt//tei:title[1]/string(.)}</title>
        <subtitle>{$doc//tei:titleStmt//tei:title[2]/string(.)}</subtitle>
        <author>{string-join( $doc//tei:titleStmt//tei:author[1]/tei:persName//text(), ' ')}</author>
        <date when="{($doc//tei:date)[1]/string(.)}">{($doc//tei:date)[1]/string(.)}</date>
        <source>http://dramawebben.se</source>
      </header>
      <personae>
    {
        for $pers in $doc//tei:listPerson//tei:listPerson[@type='cast']/tei:person
        return
            <character>
                <name>{string-join($pers//tei:persName//text(), ' ')}</name>
                <alias xml:id="{$pers/string(@xml:id)}"><name>{string-join($pers//tei:persName//text(), ' ')}</name></alias>
            </character>
    }
    </personae>
    <text>
        {
            for $act in $doc//tei:div[@type="act"]
            return
                <div>
                    {
                        for $scene in $act//tei:div[@type="scene"]
                        return
                            <div>
                                {
                                    for $speaker in distinct-values($scene//tei:sp/@who)
                                    return 
                                        <sp who="{ string-join(tokenize($speaker, '#sp'), '#') }"></sp>
                                }
                            </div>
                    }
                </div>
        }    
    </text>
    </play>
return
xmldb:store('/db/dramawebben-lina', $name, $lina)
