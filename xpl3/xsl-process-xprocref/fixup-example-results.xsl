<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ltf_d4h_ybc" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       This stylesheet changes the example results. For instance, it will remove any explicit path entries. 
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="xproc-example-elm" as="element(db:xproc-example)" required="true">
    <!-- This is the element that triggered the example processing. We need it because we process some of its attributes. -->
  </xsl:param>

  <!-- ======================================================================= -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="fixup-uris" as="xs:boolean" select="xtlc:str2bln($xproc-example-elm/@fixup-uris, true())"/>
  <xsl:variable name="output-is-text" as="xs:boolean" select="xtlc:str2bln($xproc-example-elm/@output-is-text, false())"/>
  <xsl:variable name="keep-from" as="xs:string?" select="xs:string($xproc-example-elm/@keep-from)"/>

  <xsl:variable name="file-protocol" as="xs:string" select="'file:/'"/>
  <xsl:variable name="bogus-file-prefix" as="xs:string" select="$file-protocol || '…/…/'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$output-is-text">
        <!-- When it's text it wraps the text value of the document int an <xpref:TEXT> element. This will be detected and removed later on... -->
        <xpref:TEXT>
          <xsl:value-of select="."/>
        </xpref:TEXT>
      </xsl:when>
      <xsl:otherwise> 
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="@*[starts-with(., $file-protocol)]">
    <xsl:attribute name="{node-name(.)}" select="local:fixup-uri(string(.))"/>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="text()[starts-with(., $file-protocol)]">
    <xsl:value-of select="local:fixup-uri(string(.))"/>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:fixup-uri" as="xs:string">
    <xsl:param name="contents" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="not($fixup-uris)">
        <xsl:sequence select="$contents"/>
      </xsl:when>
      <xsl:when test="exists($keep-from) and contains($contents, $keep-from)">
        <xsl:sequence select="$bogus-file-prefix || $keep-from || substring-after($contents, $keep-from)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$bogus-file-prefix || xtlc:href-name($contents)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
