xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
(: theatre-classique adapter for dlina.github.io
 : subtitle extraction my be horrible, tokenization on comma not very helpful
 : some special characters have to be replaced for a valid xml:id, some are really strange ( "THÉRIAQUE" )
 : prefaces and everything aside from title and subtitle is thrown out with the complete tei:front element
 : 
 : boyer tiridate: two castItems with same id (propably more errors of this kind, script now unaware of)
 : 
 : moliere: 	<docDate value=""></docDate> ???
 : 
 : racine: iphigenie hat zwei uraufführungen, siehe TEI dort
 : 
 :  :)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lina="http://lina.digital";
(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)
declare default element namespace "http://lina.digital";

declare function local:string2id($string, $map){
    let $string:= lower-case($string)
    let $pattern := $map[1]
    let $replacement := $map[2]
    let $result := replace($string, $pattern, $replacement )

    return
        if (count($map[position() gt 2]) lt 2) then $result else local:string2id(string($result), $map[position() gt 2])
};

declare function local:speech($div, $map) {
for $sp in distinct-values( $div/tei:sp/local:string2id(./@who, $map) )
return
    <sp who="#{ local:string2id($sp, $map) }">
        <amount n="{count( $div/tei:sp[ local:string2id(@who, $map) = $sp ] )}" unit="speech_acts"/>
        <amount n="{count( $div/tei:sp[ local:string2id(@who, $map) = $sp ]//text()[not(ancestor::tei:speaker)][not(ancestor::tei:stage)]/tokenize(., ' |\.|,|;|:') )}" unit="words"/>
        <amount n="{count( $div/tei:sp[ local:string2id(@who, $map) = $sp ]//* )}" unit="lines"/>
        <amount n="{count( $div/tei:sp[ local:string2id(@who, $map) = $sp ]//text()[not(ancestor::tei:speaker)][not(ancestor::tei:stage)]/tokenize(., '.') )}" unit="chars"/>
    </sp> 
};

declare function local:div($div, $map){
<div>
    { if($div/tei:head) then <head>{$div/tei:head/string()}</head> else() }
    { if($div/tei:sp) then local:speech($div, $map) else () }
    { if($div/tei:*[starts-with(local-name(), 'div')]) 
        then 
            for $div in $div/tei:*[starts-with(local-name(), 'div')]
                return
                    local:div($div, $map)
    else () }
</div>
};

let $path := '/data/theatre/'
let $map := (
                ' ', '_',
                "'", '_',
                ",", '_',
                '^\d', 'n$0',
                'É','E',
                '/', '_',
                '’', '_',
                '\)|\(', '_',
                '.[^a-zäüöA-ZÄÜÖ0-9_]', '_'
            )

return
for $doc at $pos in collection($path)//tei:TEI
let $test := console:log( $doc/base-uri() )
(:where $pos gt 700:)
return
let $lina:=    
        <play xmlns="http://lina.digital" id="{$pos}tc">
        <header>
            <title>{
                    let $title:= $doc/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/string()
                    let $docTitle := $doc//tei:docTitle/tei:titlePart[@type="main"]/string()
                    return if($docTitle = '') then $title else $docTitle
            }</title>
            {for $sub in $doc//tei:docTitle/tei:titlePart[@type="sub"]/string() return <subtitle>{$sub}</subtitle>}
            <genretitle>{ $doc/tei:teiHeader//tei:SourceDesc/tei:genre/string() }</genretitle>
            <author>{ $doc/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/string() }</author>
            {if(exists($doc//tei:premiere)) then <date type="premiere"  when="{($doc//tei:premiere)[1]/@date}">{ string(($doc//tei:premiere)[1]/@date) }</date> else ()}
            {if(exists($doc//tei:docDate))  then <date type="print"     when="{$doc//tei:docDate[matches(@value, '\d\d\d\d')]/@value}">{ string($doc//tei:docDate[matches(@value, '\d\d\d\d')]/@value) }</date> else ()}
            <source>https://github.com/dramacode/theatre-classique/{substring-after( $doc/base-uri(), '/db/data/theatre/' )}</source>
        </header>
        <personae>
            {for $person in distinct-values($doc//tei:sp/local:string2id(string(@who), $map))
            let $person := if ($person = '') then 'empty' else $person
            let $id := local:string2id($person, $map)
            let $castItem := ($doc//tei:castItem/tei:role[local:string2id(string(@id), $map) = $id])[1]
            return
                <character>
                    <name>{$castItem/text()}</name>
                    <alias xml:id="{ $id }">
                        <name>{$castItem/text()}</name>
                        {if(exists($castItem/@sex)) then (
                            <sex> {
                                switch($castItem/string(@sex)) 
                                case "1" return 'm'
                                case "2" return "f"
                                default return "0"} 
                            </sex>) else ()}
                    </alias>
                </character>
            }
        </personae>
        <text>
            {
                for $div in $doc//tei:body/tei:div1[descendant::tei:sp]
                return
                    local:div($div, $map)
            }
        </text>
    </play>
return
    xmldb:store('/db/data/theatre-lina', $lina//lina:source/substring-after(.,'theatre-classique/'), $lina)