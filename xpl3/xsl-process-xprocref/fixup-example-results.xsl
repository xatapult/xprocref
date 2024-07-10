<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ltf_d4h_ybc"
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
  <xsl:variable name="keep-from" as="xs:string?" select="xs:string($xproc-example-elm/@keep-from)"/>
  
  
  <xsl:variable name="bogus-file-prefix" as="xs:string" select="'file:/…/…/'"/>

  <!-- ================================================================== -->

  <xsl:template match="@*[starts-with(., 'file:/')]">
    <xsl:variable name="attribute-contents" as="xs:string" select="xs:string(.)"/>
    <xsl:variable name="new-attribute-contents" as="xs:string">
      <xsl:choose>
        <xsl:when test="not($fixup-uris)">
          <xsl:sequence select="$attribute-contents"/>
        </xsl:when>
        <xsl:when test="exists($keep-from) and contains($attribute-contents, $keep-from)">
          <xsl:sequence select="$bogus-file-prefix || $keep-from || substring-after($attribute-contents, $keep-from)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$bogus-file-prefix || xtlc:href-name($attribute-contents)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="{node-name(.)}" select="$new-attribute-contents"/>
  </xsl:template>

</xsl:stylesheet>
