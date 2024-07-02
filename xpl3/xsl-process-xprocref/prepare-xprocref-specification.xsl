<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.cbg_j4m_vbc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Prepares the XProcRef specification by:
       * Adding identifiers to all steps
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="xpref:step">
    <!-- Make sure some optional attributes are filled in. -->
    <xsl:copy>
      <xsl:if test="empty(@id)">
        <xsl:attribute name="id" select="string-join(('step', @version-idref, @name, generate-id(.)), '.')"/>
      </xsl:if>
      <xsl:if test="empty(@namespace-prefix)">
        <xsl:attribute name="namespace-prefix" select="$xpref:default-namespace-prefix"/>
      </xsl:if>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="*:xproc-example[exists(@href)]">
    <xsl:copy>
      <xsl:variable name="href-xml-base" as="xs:string" select="(ancestor-or-self::*[exists(@xml:base)])[last()]/@xml:base => string()"/>
      <xsl:attribute name="href" select="resolve-uri(@href, $href-xml-base) => xtlc:href-canonical()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
