<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.mwk_hxj_5bc"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Creates an index for all the XProcRef stuff from the (enhanced) source.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xprocref-index timestamp="{current-dateTime()}">
      <!-- Steps per version: -->
      <xsl:apply-templates select="/*/xpref:versions/xpref:version"/>
      <!-- Categories: -->
      <!-- TBD -->
    </xprocref-index>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:version">
    <!-- The version is our main entry. -->
    <xsl:variable name="version-id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="steps-for-version" as="element(xpref:step)" select="/*/xpref:steps/xpref:step[@version-idref eq $version-id]"/>
    <xsl:variable name="category-ids-for-version" as="xs:string*"
      select="(for $step in $steps-for-version return xtlc:str2seq($step/@category-idrefs)) => distinct-values()"/>

    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <!-- Steps for this version: -->
      <xsl:for-each select="$steps-for-version">
        <xsl:copy>
          <xsl:apply-templates select="(@id, @name, @category-ids, @short-description)"/>

          <!-- What categories is this step in? -->
          <xsl:for-each select="xtlc:str2seq(@category-idrefs)">
            <!-- Some ordering! function? -->
            <category idref="{.}"/>
          </xsl:for-each>

          <!-- What other version is  this step in: -->
          <!-- Some ordering! function? -->

        </xsl:copy>
      </xsl:for-each>




      <!-- Categories for this version -->
      <xsl:variable name="category-ids-for-version" as="xs:string*"
        select="(for $step in $steps-for-version return xtlc:str2seq($step/@category-idrefs)) => distinct-values()"/>
      <xsl:comment> == Categories for this version: == </xsl:comment>
      <xsl:for-each select="$category-ids-for-version">
        <category idref="{.}"/>
      </xsl:for-each>
    </xsl:copy>

  </xsl:template>


</xsl:stylesheet>
