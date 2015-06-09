# textgrid-repository-dramas

* contains the 666 dramatic pieces we extracted from the original TextGrid Repository
  (http://www.textgrid.de/fileadmin/digitale-bibliothek/literatur-nur-texte-2.zip)
* filenames consist of author, title, and year – 'year' being automatically extracted
  from the metadata in the original XML files, sometimes being the year of first
  publication, sometimes just being the lifespan of the author – not really reliable
  information, but good enough for a rough temporal classification of a play

We renamed the files with the following script:
``` xquery
xquery version "3.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
let $collection := '/db/data/textgrid-repository-dramas/'
return

((for $filename in xmldb:get-child-resources($collection)
let $doc := doc($collection || $filename)
let $noteStmt := for $item in tokenize($doc//tei:notesStmt/tei:note, '\W')[matches(., '\d{3,4}')] return number($item)
let $noteStmt := number(min($noteStmt))[1]
let $noteStmt := if ($doc//tei:creation/tei:date/@when or $doc//tei:creation/tei:date/string-length() = 4)
                    then min((number(min($doc//tei:creation/tei:date/@when)), if ($doc//tei:creation/tei:date/string-length() = 4) then number($doc//tei:creation/tei:date/string()) else ()) )
                    else $noteStmt
let $noteStmt := if ($noteStmt gt min($doc//tei:profileDesc/tei:creation/tei:date/number(@notAfter)))
                    then $doc//tei:profileDesc/tei:creation/tei:date/@notAfter
                    else $noteStmt
(: ok, if we still have no date, we look for the pubStmt and compare with creation@notAfter :)
let $noteStmt :=
        if (string($noteStmt) = 'NaN') 
            then 
                let $pub := number($doc//tei:biblFull/tei:publicationStmt/tei:date/@when)
                let $creation := number($doc//tei:profileDesc/tei:creation/tei:date/@notAfter)
                return 
                min(($pub, $creation))
            else 
            $noteStmt
let $noteStmt :=
        if (string($noteStmt) = 'NaN') then number($doc//tei:profileDesc/tei:creation/tei:date/@notAfter) else $noteStmt
let $noteStmt := if (string-length($noteStmt) = 3) then 'BC0' || $noteStmt else $noteStmt

let $target := $noteStmt || '_' || replace(string(($doc//tei:author)[1]), '\s+', '_') || '_-_' || replace(($doc//tei:fileDesc[1]/tei:titleStmt/tei:title/string())[1], '\s+', '_')
let $mv  :=
"mv '" || replace(xmldb:decode($filename), "[']",  "'\\$0'") || "' '" || replace($target, "[']",  "'\\$0'") || ".xml'
"

(:replace($mv, "[!|\(|\)|,|'|:|;|-]", '\\$0'):)
return
    $mv)
    ,   "
mv 'Aischylos_-_Der_gefesselte_Proemetheus_(-0525--0456).xml' 'BC0470_Aischylos_-_Der_gefesselte_Proemetheus.xml'
mv 'Aischylos_-_Die_Orestie_(-0525--0456).xml' 'BC0456_Aischylos_-_Die_Orestie.xml'
mv 'Euripides_-_Iphigenie_in_Aulis_(-0480--0406).xml' 'BC0406_Euripides_-_Iphigenie_in_Aulis.xml'
mv 'Euripides_-_Medea_(-0480--0406).xml' 'BC0431_Euripides_-_Medea.xml'
mv 'Plautus,_Titus_Maccius_-_Amphitryon_(-0250--0184).xml' 'BC0207_Plautus,_Titus_Maccius_-_Amphitryon.xml'
" )
```
