<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.nyw_5fq_w2c"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Replaces all links, which are URIs because of the website production, into identifier links.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="anchor-character" as="xs:string" select="'#'"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlcon:document[exists(@xml:id)]">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()">
        <xsl:with-param name="base-id" as="xs:string" select="xs:string(@xml:id)" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*/@xlink:href[starts-with(., $anchor-character)]" priority="100">
    <xsl:param name="base-id" as="xs:string" required="true" tunnel="true"/>
    <xsl:attribute name="linkend" select="$base-id || $xpref:identifier-separator || xtlc:str2id(substring-after(., $anchor-character))"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*/@xlink:href[local:is-replaceable-link(.)]" priority="10">
    <!-- Replace this by the identifier of the document it points to. Anchors make things a bit complicated... -->

    <xsl:variable name="href-link" as="xs:string" select="xs:string(.)"/>
    <xsl:variable name="contains-anchor" as="xs:boolean" select="contains($href-link, $anchor-character)"/>
    <xsl:variable name="uri" as="xs:string" select="if ($contains-anchor) then substring-before($href-link, $anchor-character) else $href-link"/>
    <xsl:variable name="anchor" as="xs:string?" select="if($contains-anchor) then substring-after($href-link, $anchor-character) else ()"/>

    <xsl:variable name="document-identifier" as="xs:string" select="/*/xtlcon:document[@href-target eq $uri]/@xml:id"/>
    <xsl:attribute name="linkend" select="$document-identifier || (if ($contains-anchor) then ($xpref:identifier-separator || xtlc:str2id($anchor)) else ())"/>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="db:xref[exists(@linkend)]">
    <xsl:param name="base-id" as="xs:string" required="true" tunnel="true"/>
    <xsl:copy>
      <xsl:attribute name="linkend" select="$base-id || $xpref:identifier-separator || xtlc:str2id(@linkend)"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- ======================================================================= -->

  <xsl:function name="local:is-replaceable-link" as="xs:boolean">
    <xsl:param name="link" as="xs:string"/>
    <xsl:sequence select="not(xtlc:href-is-absolute($link)) and not(starts-with($link, 'mailto:'))"/>
  </xsl:function>

</xsl:stylesheet>
