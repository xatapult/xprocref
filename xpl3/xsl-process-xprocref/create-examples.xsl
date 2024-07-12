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
  <xsl:mode name="mode-prepare-pipeline-for-display" on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="xproc-example-elm" as="element(db:xproc-example)" required="true">
    <!-- This is the element that triggered the example processing. We need it because we process some of its attributes. -->
  </xsl:param>

  <!-- ======================================================================= -->

  <xsl:variable name="fixup-pipeline-input" as="xs:boolean" select="xtlc:str2bln($xproc-example-elm/@fixup-pipeline-input, true())"/>

  <!-- ======================================================================= -->

  <xsl:template match="db:xproc-example">

    <xsl:variable name="show-source" as="xs:boolean" select="xtlc:str2bln(@show-source, true())"/>
    <xsl:variable name="show-pipeline" as="xs:boolean" select="xtlc:str2bln(@show-pipeline, true())"/>
    <xsl:variable name="show-result" as="xs:boolean" select="xtlc:str2bln(@show-result, true())"/>

    <xsl:variable name="href-pipeline" as="xs:string" select="xs:string(@href)"/>
    <xsl:variable name="example-pipeline" as="document-node()" select="doc($href-pipeline)"/>

    <!-- Source document: -->
    <xsl:if test="$show-source">
      <xsl:variable name="source-port-elm" as="element(p:input)" select="$example-pipeline/*/p:input[@port eq 'source']"/>
      <xsl:variable name="href-input" as="xs:string?">
        <xsl:choose>
          <xsl:when test="exists($source-port-elm/@href)">
            <xsl:sequence select="$source-port-elm/@href"/>
          </xsl:when>
          <xsl:when test="exists($source-port-elm/p:document/@href)">
            <xsl:sequence select="$source-port-elm/p:document/@href"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- No reference to an input document with an @href. -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="source-document-root-elm" as="element()">
        <xsl:choose>
          <xsl:when test="exists($href-input)">
            <xsl:variable name="href-full" as="xs:string" select="resolve-uri($href-input, base-uri($source-port-elm))"/>
            <xsl:sequence select="doc($href-full)/*"/>
          </xsl:when>
          <xsl:when test="exists($source-port-elm/p:inline)">
            <xsl:sequence select="$source-port-elm/p:inline/*[1]"/>
          </xsl:when>
          <xsl:when test="exists($source-port-elm/*)">
            <xsl:sequence select="$source-port-elm/*[1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts" select="('Could not resolve source document for XProc example pipeline ', xtlc:q($href-pipeline))"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:call-template name="process-header">
        <xsl:with-param name="header-elm" select="db:source-header"/>
        <xsl:with-param name="document-type" select="'source'"/>
      </xsl:call-template>

      <xsl:call-template name="xpref:list-document">
        <xsl:with-param name="root-elm" select="$source-document-root-elm"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Pipeline document: -->
    <xsl:if test="$show-pipeline">
      <xsl:call-template name="process-header">
        <xsl:with-param name="header-elm" select="db:pipeline-header"/>
        <xsl:with-param name="document-type" select="'pipeline'"/>
      </xsl:call-template>
      <xsl:call-template name="xpref:list-document">
        <xsl:with-param name="root-elm" select="local:prepare-pipeline-for-display($example-pipeline/*)"/>
        <xsl:with-param name="preserve-space" select="true()"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Result document: -->
    <xsl:if test="$show-result">
      <xsl:call-template name="process-header">
        <xsl:with-param name="header-elm" select="db:result-header"/>
        <xsl:with-param name="document-type" select="'result'"/>
      </xsl:call-template>
      <xsl:call-template name="xpref:list-document">
        <xsl:with-param name="root-elm" select="_RESULT/*[1]"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- PREPARE PIPELINE: -->

  <xsl:function name="local:prepare-pipeline-for-display" as="element(p:declare-step)">
    <xsl:param name="xpl" as="element(p:declare-step)"/>
    <xsl:choose>
      <xsl:when test="$fixup-pipeline-input">
        <xsl:apply-templates select="$xpl" mode="mode-prepare-pipeline-for-display"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$xpl"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:input[@port eq 'source']/node()" mode="mode-prepare-pipeline-for-display">
    <!-- Remove... -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="p:input[@port eq 'source']/@href" mode="mode-prepare-pipeline-for-display">
    <!-- Remove... -->
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- OTHER SUPPORT: -->

  <xsl:template name="process-header">
    <xsl:param name="header-elm" as="element()?" required="true">
      <!-- The *-header element from the input, if any. -->
    </xsl:param>
    <xsl:param name="document-type" as="xs:string" required="true"/>

    <xsl:choose>
      <xsl:when test="empty($header-elm)">
        <!-- Create a default text: -->
        <db:para role="keep-with-next">{xtlc:capitalize($document-type)} document:</db:para>
      </xsl:when>
      <xsl:when test="$header-elm/*">
        <xsl:copy-of select="$header-elm/*"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No header. -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
