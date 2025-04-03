<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.nyw_5fq_w2c"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Makes sure everything that needs to have an identifier has one.
       Also takes care of making all identifiers unique (given that we're going to merge everything).
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlcon:document[exists(@href-target)]">
    <!-- We're going to use the target URI as the base for all identifiers in this article. -->
    <xsl:variable name="base-id" as="xs:string" select="xtlc:str2id(@href-target)"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="$base-id"/>
      <xsl:apply-templates select="(@* except @xml:id) | node()">
        <xsl:with-param name="base-id" as="xs:string" select="$base-id" tunnel="true"/>
        <xsl:with-param name="href-target" as="xs:string" select="xs:string(@href-target)" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:article">
    <xsl:param name="base-id" as="xs:string" required="true" tunnel="true"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="$base-id"/>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*[exists(@xml:id)]">
    <xsl:param name="base-id" as="xs:string" required="true" tunnel="true"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="$base-id || $xpref:identifier-separator || xtlc:str2id(@xml:id)"/>
      <xsl:apply-templates select="(@* except @xml:id) | node()"/>
    </xsl:copy>
  </xsl:template>
 
  <!-- ======================================================================= -->
  <!-- The following templates ensures all remaining @xlink:href attributes are "absolute", 
       so we can use them to find identifiers quickly. -->

  <xsl:template match="@xlink:href[local:is-replaceable-link(.)]">
    <xsl:param name="href-target" as="xs:string" required="true" tunnel="true"/>

    <xsl:attribute name="xlink:href" select="xtlc:href-concat((xtlc:href-path($href-target), xs:string(.))) => xtlc:href-canonical()"/>
  </xsl:template>
  
  <!-- ======================================================================= -->
  
  <xsl:function name="local:is-replaceable-link" as="xs:boolean">
    <xsl:param name="link" as="xs:string"/>
    <xsl:sequence select="not(xtlc:href-is-absolute($link)) and not(starts-with($link, 'mailto:')) and not(starts-with($link, '#'))"/>
  </xsl:function>
  
</xsl:stylesheet>
