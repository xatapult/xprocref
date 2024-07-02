<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.oxf_4nc_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:p="http://www.w3.org/ns/xproc" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Processes all the examples
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-remove-unused-namespaces" on-no-match="shallow-copy"/>
  <xsl:mode name="mode-prepare-pipeline-for-display" on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:variable name="standard-serialization" as="map(*)" select="map{'indent': true(), 'omit-xml-declaration': true()}"/>

  <!-- ======================================================================= -->

  <xsl:template match="db:xproc-example">

    <xsl:variable name="href" as="xs:string" select="xs:string(@href)"/>
    <xsl:variable name="example-pipeline" as="document-node()" select="doc($href)"/>

    <xsl:variable name="input-document" as="element()" select="$example-pipeline/*/p:input[@port eq 'source']/p:inline/*[1] => local:remove-unused-namespaces()"/>
    <xsl:variable name="pipeline-for-display" as="element(p:declare-step)" select="$example-pipeline/* => local:prepare-pipeline-for-display()"/>
    
    <para>Input document:</para>
    <programlisting xml:space="preserve"><xsl:value-of select="serialize($input-document, $standard-serialization)"/></programlisting>

    <para>Pipeline:</para>
    <programlisting xml:space="preserve"><xsl:value-of select="serialize($pipeline-for-display, $standard-serialization)"/></programlisting>

  </xsl:template>
  
  <!-- ======================================================================= -->
  <!-- PREPARE PIPELINE: -->
  
  <xsl:function name="local:prepare-pipeline-for-display" as="element(p:declare-step)">
    <xsl:param name="xpl" as="element(p:declare-step)"/>
    <xsl:apply-templates select="$xpl" mode="mode-prepare-pipeline-for-display"></xsl:apply-templates>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="p:input[@port eq 'source']/node()" mode="mode-prepare-pipeline-for-display">
    <!-- Remove... -->
  </xsl:template>
  
  <!-- ======================================================================= -->
  <!-- REMOVE UNUSED NAMESPACES -->

  <xsl:function name="local:remove-unused-namespaces" as="element()">
    <xsl:param name="in" as="element()"/>
    <xsl:apply-templates select="$in" mode="mode-remove-unused-namespaces"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="*" mode="mode-remove-unused-namespaces">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>




</xsl:stylesheet>
