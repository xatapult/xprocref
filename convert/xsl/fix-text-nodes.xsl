<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.stn_qvj_wbc"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Fixes text nodes (removes superfluous spacing, etc.)
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="text()[normalize-space(.) ne '']">
    <xsl:variable name="text" as="xs:string" select="xs:string(.)"/>
    <xsl:variable name="has-leading-whitespace" as="xs:boolean" select="matches($text, '^\s+')"/>
    <xsl:variable name="has-trailing-whitespace" as="xs:boolean" select="matches($text, '\s+$')"/>

    <xsl:variable name="parts" as="xs:string+">
      <xsl:if test="$has-leading-whitespace">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:sequence select="normalize-space($text)"/>
      <xsl:if test="$has-trailing-whitespace">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="string-join($parts)"/>
  </xsl:template>

</xsl:stylesheet>
