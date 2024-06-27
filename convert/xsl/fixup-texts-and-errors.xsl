<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hfk_mxb_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Fixup things for the texts from the specification.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="href-bibliorefs-replacement" as="xs:string" select="resolve-uri('../data/bibliorefs-replacements.xml', static-base-uri())"/>
  <xsl:variable name="bibliorefs-replacments" as="document-node()" select="doc($href-bibliorefs-replacement)"/>

  <!-- ======================================================================= -->

  <xsl:template match="xpref:simplesect">
    <bridgehead>{normalize-space(xpref:title)}</bridgehead>
    <xsl:apply-templates select="* except xpref:title"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:section">
    <xsl:variable name="depth" as="xs:integer" select="count(ancestor-or-self::xpref:section)"/>
    <xsl:element name="sect{$depth + 1}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:rng-pattern">
    <para>
      <emphasis role="bold">[RNG Pattern {@name}]</emphasis>
    </para>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:biblioref">
    <xsl:variable name="linkend" as="xs:string" select="xs:string(@linkend)"/>
    <xsl:variable name="replacment" as="element(xpref:biblioref)?" select="$bibliorefs-replacments/*/xpref:biblioref[@linkend eq $linkend][1]"/>
    <xsl:choose>
      <xsl:when test="exists($replacment)">
        <xsl:copy-of select="$replacment/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Could not find biblioref ', xtlc:q($linkend), ' in ', xtlc:q($href-bibliorefs-replacement))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- ERRORS: -->

  <xsl:template match="xpref:step[exists(.//xpref:error)] ">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <step-errors>
        <xsl:for-each-group select=".//xpref:error" group-by="xs:string(@code)">
          <xsl:for-each select="current-group()[1]">
            <step-error code="{current-grouping-key()}">
              <description>
                <para>
                  <xsl:apply-templates/>
                </para>
              </description>
            </step-error>
          </xsl:for-each>
        </xsl:for-each-group>
      </step-errors>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:error">
    <xsl:variable name="code" as="xs:string" select="xs:string(@code)"/>
    <emphasis role="bold">[ERROR <step-error-ref code="{$code}"/>]</emphasis>
  </xsl:template>

</xsl:stylesheet>
