<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:lina="http://lina.digital"
	exclude-result-prefixes="xs" version="2.0">
	
	<xsl:output method="text"/>
	
	<xsl:template match="/">
		<xsl:apply-templates select="//tei:body/tei:div[@type='act']//tei:head | //tei:body/tei:div[@type='act']//tei:sp"/>
		<xsl:variable name="t1">
			<xsl:value-of select="concat(substring-before((/tei:TEI/tei:teiHeader//tei:author)[1], ','),
				'-',
				substring-before((/tei:TEI/tei:teiHeader//tei:title)[1], ' '))"/>
		</xsl:variable>
		
		<xsl:for-each select="//tei:div[@type='act']">
			<xsl:variable name="act">
				<xsl:value-of select="concat('akt_', position())"/>
			</xsl:variable>
			<xsl:result-document href="{concat($t1, '-', $act, '.txt')}" method="text">
				<xsl:apply-templates select="descendant::tei:sp/tei:l | descendant::tei:sp/tei:p"/>
			</xsl:result-document>
		</xsl:for-each>
		
		<xsl:for-each-group select="//tei:sp" group-by="lina:sp(tei:speaker)">
			<xsl:result-document href="{concat($t1, '-', current-grouping-key(), '.txt')}" method="text">
				<xsl:for-each select="current-group()">
					<xsl:text>
</xsl:text>
					<xsl:apply-templates select="tei:l | tei:p"/>
				</xsl:for-each>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="tei:sp">
		<xsl:apply-templates select="tei:speaker"/>
		<xsl:apply-templates select="tei:l | tei:p"/>
	</xsl:template>
	
	<xsl:template match="tei:l | tei:p">
		<xsl:value-of select="normalize-space()"/>
	</xsl:template>
	
	<xsl:template match="tei:speaker">
		<xsl:text>

</xsl:text>
		<xsl:value-of select="lina:sp(.)"/>
		<xsl:text>
</xsl:text>
	</xsl:template>
	
	<xsl:function name="lina:sp">
		<xsl:param name="speaker"/>
		<xsl:choose>
			<xsl:when test="matches($speaker, '.*\.\s?')">
				<xsl:value-of select="normalize-space(substring-before($speaker, '.'))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($speaker)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
