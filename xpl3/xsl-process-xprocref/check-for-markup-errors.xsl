<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.mbl_g2y_zbc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Check for markup errors (these are in the contents using a special text marker) and report these.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-find-errors" on-no-match="shallow-skip"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="full-page-extension" as="xs:string" select="'.' || $xpref:page-extension"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <!-- Find and report the errors: -->
    <xsl:variable name="markup-errors" as="xs:string*">
      <xsl:apply-templates select="*" mode="mode-find-errors"/>
    </xsl:variable>
    <xsl:if test="exists($markup-errors)">
      <xsl:message>  * WARNING: Markup errors found:</xsl:message>
      <xsl:for-each select="$markup-errors">
        <xsl:message>    * {.}</xsl:message>
      </xsl:for-each>
    </xsl:if>

    <!-- And just copy the input verbatim: -->
    <xsl:sequence select="."/>

  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template match="/*/xtlcon:document[exists(@href-target)]" mode="mode-find-errors" as="xs:string?">
    <xsl:if test="exists(.//text()[contains(., $xpref:error-start-marker)])">
      <xsl:variable name="target" as="xs:string" select="xs:string(@href-target)"/>
      <xsl:sequence select="if (ends-with($target, $full-page-extension)) then substring-before($target, $full-page-extension) else $target"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
