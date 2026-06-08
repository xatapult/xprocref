<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rlq_31g_njc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true"
  xmlns="http://www.xtpxlib.nl/ns/xprocref" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref">
  <!-- ================================================================== -->
  <!-- 
       This converts a document from a source sub-tree into one for a new version.
       Converts everything we can encounter. Raises an error if something unexpected shows up. 
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-convert-step-group" on-no-match="shallow-copy"/>

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:param name="source-version" as="xs:string" required="true"/>
  <xsl:param name="target-version" as="xs:string" required="true"/>

  <xsl:variable name="source-version-no-dots" as="xs:string" select="replace($source-version, '[^0-9a-zA-Z]', '')"/>
  <xsl:variable name="target-version-no-dots" as="xs:string" select="replace($target-version, '[^0-9a-zA-Z]', '')"/>

  <xsl:variable name="source-version-internal" as="xs:string" select="'v' || $source-version-no-dots"/>
  <xsl:variable name="target-version-internal" as="xs:string" select="'v' || $target-version-no-dots"/>

  <xsl:variable name="regexp-source-version-macrodef" as="xs:string" select="'V' || $source-version-no-dots || '\}'"/>
  <xsl:variable name="target-version-macrodef-replacement" as="xs:string" select="'V' || $target-version-no-dots || '}'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- <step> and <step-identity> elements: -->

  <xsl:template match="/xpref:step | /xpref:step-identity ">
    <step-identity>
      <xsl:copy-of select="(@name, @xsi:schemaLocation)"/>

      <xsl:attribute name="name" select="xs:string(@name)"/>
      <xsl:attribute name="version-idref" select="$target-version-internal"/>
      <xsl:attribute name="base-version-idref" select="$source-version-internal"/>
      <xsl:attribute name="href-specification" select="local:replace-macro-version(@href-specification)"/>

    </step-identity>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- <step-group> elements: -->

  <xsl:template match="/xpref:step-group">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="mode-convert-step-group"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:macrodef/@value" mode="mode-convert-step-group">
    <xsl:attribute name="{local-name()}" select="local:replace-macro-version(.)"/>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template match="/*" priority="-1">
    <xsl:call-template name="xtlc:raise-error">
      <xsl:with-param name="msg-parts" select="('Unhandled document encountered: root element ', local-name(.))"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:function name="local:replace-macro-version" as="xs:string">
    <xsl:param name="in" as="xs:string"/>

    <xsl:sequence select="replace($in, $regexp-source-version-macrodef, $target-version-macrodef-replacement)"/>
  </xsl:function>

</xsl:stylesheet>
