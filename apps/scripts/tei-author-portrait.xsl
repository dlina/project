<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dct="http://purl.org/dc/terms/"    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"    
    xmlns:wdt="http://www.wikidata.org/prop/direct/"      
    exclude-result-prefixes="dct xs tei rdf rdfs wdt"
    version="2.0">
    
    <dct:contributor>
        <rdf:value>http://d-nb.info/gnd/1017477760</rdf:value>
        <rdfs:label>Martin de la Iglesia</rdfs:label>
    </dct:contributor>
    <dct:license rdf:resource="https://creativecommons.org/licenses/by/4.0/"/>
    
    <xsl:template match="/">        
        <!-- Enter TEI source here: -->
        <xsl:variable name="teiurl" select="'http://textgridrep.org/textgrid:jn0f'"/>
        
        <xsl:for-each select="document($teiurl)//tei:author">
            <xsl:variable select="./@key" name="key"/>                        
            <xsl:variable name="authorname" select="."/>                
            <xsl:variable name="gndurl" select="concat('http://d-nb.info/gnd/',substring-after($key, 'pnd:'))"/>
            <xsl:choose>
                <xsl:when test="contains(unparsed-text($gndurl), 'Nachweis der Quelle')">  
                    <xsl:call-template name="WPtoWD">
                        <xsl:with-param name="wpurl" select="substring-after(substring-after(substring-before(unparsed-text($gndurl), '&quot; onclick=&quot;window.open(this.href); return false;&quot; title=&quot;Zugehöriger Artikel in wikipedia.de'),'Nachweis der Quelle'),'href=&quot;')"/>
                        <xsl:with-param name="authorname" select="$authorname"/>
                    </xsl:call-template>                                    
                </xsl:when>
                <xsl:otherwise>          
                    <xsl:call-template name="WPtoWD">
                        <xsl:with-param name="wpurl" select="substring-after(substring-after(substring-before(unparsed-text($gndurl), '&quot; onclick=&quot;window.open(this.href); return false;&quot; title=&quot;Zugehöriger Artikel in wikipedia.de'),'Korrekturanfrage'),'href=&quot;')"/>
                        <xsl:with-param name="authorname" select="$authorname"/>
                    </xsl:call-template>
                </xsl:otherwise>                           
            </xsl:choose>                 
        </xsl:for-each>                 
    </xsl:template>       
    
    <xsl:template name="WPtoWD">
        <xsl:param name="wpurl"/>
        <xsl:param name="authorname"/>                        
        <xsl:variable name="wdurl" select="concat('http:',document($wpurl)//li[@id='t-wikibase']/a/@href)"/>
        <xsl:variable name="wdid" select="substring-after($wdurl,'//www.wikidata.org/wiki/')"/>
        <xsl:variable name="wdrdfurl" select="concat('https://www.wikidata.org/wiki/Special:EntityData/',$wdid,'.rdf')"/>                    
        <xsl:result-document href="dlina-portrait.html" method="html">
            <html>
                <body>                                
                    <xsl:choose>                                    
                        <xsl:when test="not(count(document($wdrdfurl)/rdf:RDF/rdf:Description/wdt:P18/@rdf:resource) > 0)">  
                            <xsl:call-template name="WDtoHTML">
                                <xsl:with-param name="authorname" select="$authorname"/>
                                <xsl:with-param name="wdrdfurl" select="$wdrdfurl"/>
                                <xsl:with-param name="src" select="'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC8b6igoqKDW9OdxHOJPS_DX0h_rFNxVVjkKhADdBPetrZJjsH'"/>
                            </xsl:call-template>                                        
                        </xsl:when>                  
                        <xsl:otherwise>                                        
                            <xsl:call-template name="WDtoHTML">
                                <xsl:with-param name="authorname" select="$authorname"/>
                                <xsl:with-param name="wdrdfurl" select="$wdrdfurl"/>
                                <xsl:with-param name="src" select="document($wdrdfurl)/rdf:RDF/rdf:Description/wdt:P18[1]/@rdf:resource"/>
                            </xsl:call-template>
                        </xsl:otherwise>                                
                    </xsl:choose>                                
                </body>
            </html>
        </xsl:result-document>     
    </xsl:template>
    
    <xsl:template name="WDtoHTML">
        <xsl:param name="wdrdfurl"/>
        <xsl:param name="authorname"/>
        <xsl:param name="src"/>        
        <img>
            <xsl:attribute name="birth" select="substring(document($wdrdfurl)/rdf:RDF/rdf:Description/wdt:P569[1],1,4)"/>
            <xsl:attribute name="authorname" select="$authorname"/>
            <xsl:attribute name="gender">
                <xsl:if test="document($wdrdfurl)/rdf:RDF/rdf:Description/wdt:P21[@rdf:resource='http://www.wikidata.org/entity/Q6581072']">
                    <xsl:value-of>female</xsl:value-of>
                </xsl:if>
                <xsl:if test="document($wdrdfurl)/rdf:RDF/rdf:Description/wdt:P21[@rdf:resource='http://www.wikidata.org/entity/Q6581097']">
                    <xsl:value-of>male</xsl:value-of>
                </xsl:if>
            </xsl:attribute>
            <xsl:attribute name="src" select="$src"/>
        </img>        
    </xsl:template>
    
</xsl:stylesheet>
