<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rfp_2dj_5bc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Some shared definitions for the stylesheets in XProcRef.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- GENERIC: -->
  
  <xsl:variable name="xpref:page-extension" as="xs:string" select="'html'"/>

  <!-- ======================================================================= -->
  <!-- PAGE NAMES: -->

  <!-- Main pages: -->
  <xsl:variable name="xpref:name-home-page" as="xs:string" select="'index.' || $xpref:page-extension"/>
  <xsl:variable name="xpref:name-versions-overview-page" as="xs:string" select="'versions.' || $xpref:page-extension"/>
  <xsl:variable name="xpref:name-about-page" as="xs:string" select="'about.' || $xpref:page-extension"/>

  <!-- Pages within a specific version (will be in a subdirectory for this version): -->
  <xsl:variable name="xpref:name-version-home-page" as="xs:string" select="$xpref:name-home-page"/>
  <xsl:variable name="xpref:name-categories-overview-page" as="xs:string" select="'categories.' || $xpref:page-extension"/>

  <!-- ======================================================================= -->
  <!-- FILE NAME SUPPORT: -->

  <xsl:function name="xpref:href-combine" as="xs:string">
    <xsl:param name="pre-path-components" as="xs:string*"/>
    <xsl:param name="version-name" as="xs:string?"/>
    <xsl:param name="filename" as="xs:string"/>

    <xsl:sequence
      select="xtlc:href-concat(($pre-path-components, if (exists($version-name)) then xtlc:str2filename-safe($version-name) else (), $filename))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xpref:href-combine" as="xs:string">
    <xsl:param name="version-name" as="xs:string?"/>
    <xsl:param name="filename" as="xs:string"/>

    <xsl:sequence select="xpref:href-combine((), $version-name, $filename)"/>
  </xsl:function>

</xsl:stylesheet>
