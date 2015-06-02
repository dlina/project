<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <ns uri="http://lina.digital" prefix="lina"/>
    <pattern>
        <title>who</title>
        <rule context="lina:sp">
        <let name="results" value="
            for $val in tokenize(normalize-space(@who),'\s+')
            return starts-with($val,'#') and //lina:alias[@xml:id=substring($val,2)]"/>
        <assert test="every $x in $results satisfies $x">
            Character unbekannt: <value-of select="$results"/>
        </assert>
        </rule>
    </pattern>
</schema>