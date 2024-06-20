<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.qtv_2nd_5bc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:db="http://docbook.org/ns/docbook" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       TBD DESCR
       
       Input is the (normalized and enhanced) XProcRef definition.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-process-text" on-no-match="fail"/>
  <xsl:mode name="mode-process-text-inner-elements" on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="namespace-xdoc" as="xs:string" select="'http://www.xtpxlib.nl/ns/xdoc'"/>
  <xsl:variable name="namespace-docbook" as="xs:string" select="'http://docbook.org/ns/docbook'"/>

  <xsl:variable name="namespaces-leave-unchanged" as="xs:string+" select="($namespace-docbook, $namespace-xdoc)"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlcon:document-container timestamp="{current-dateTime()}">

      <!-- Home page: -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="$xpref:name-index-page"/>
        <xsl:with-param name="title" select="'HOME PAGE TBD'"/>
        <xsl:with-param name="content">
          <db:para>TBD</db:para>
        </xsl:with-param>
      </xsl:call-template>
      
      <!-- Versions main page -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="$xpref:name-versions-page"/>
        <xsl:with-param name="title" select="'VERSIONS PAGE TBD'"/>
        <xsl:with-param name="content">
          <db:para>TBD</db:para>
        </xsl:with-param>
      </xsl:call-template>
      
      <!-- About main page -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="$xpref:name-about-page"/>
        <xsl:with-param name="title" select="'ABOUT PAGE TBD'"/>
        <xsl:with-param name="content">
          <db:para>TBD</db:para>
        </xsl:with-param>
      </xsl:call-template>

      <!-- Process this per version: -->
      <xsl:apply-templates select="/*/xpref:versions/xpref:version"/>

    </xtlcon:document-container>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- PROCESS VERSION: -->

  <xsl:template match="xpref:version">

    <xsl:variable name="version-name" as="xs:string" select="xs:string(@name)"/>
    <xsl:variable name="version-subdir-name" as="xs:string" select="xtlc:str2filename-safe($version-name)"/>
    <xsl:variable name="version-id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="steps-for-version" as="element(xpref:step)*" select="/*/xpref:steps/xpref:step[string(@version-idref) eq $version-id]"/>

    <!-- Find out whether there are any steps at all for this version: -->
    <xsl:choose>
      <xsl:when test="exists($steps-for-version)">
        <xsl:comment> == START VERSION {$version-name} ({$version-id}) == </xsl:comment>

        <!-- Home page for version: -->
        <xsl:call-template name="create-docbook-article">
          <xsl:with-param name="href-target" select="xtlc:href-concat(($version-subdir-name, $xpref:name-index-page))"/>
          <xsl:with-param name="version-id" select="$version-id"/>
          <xsl:with-param name="title" select="'HOME PAGE ' || $version-name"/>
          <xsl:with-param name="content">
            <xsl:call-template name="process-text">
              <xsl:with-param name="surrounding-elm" select="xpref:description"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>

        <!-- Categories page for version: -->
        <xsl:call-template name="create-docbook-article">
          <xsl:with-param name="href-target" select="xtlc:href-concat(($version-subdir-name, $xpref:name-categories-page))"/>
          <xsl:with-param name="title" select="'CATEGORIES VERSION ' || $version-name"/>
          <xsl:with-param name="version-id" select="$version-id"/>
          <xsl:with-param name="content">
            <db:para>TBD</db:para>
          </xsl:with-param>
        </xsl:call-template>

        <!-- All steps for version: -->
        <xsl:apply-templates select="$steps-for-version">
          <xsl:with-param name="version-subdir-name" as="xs:string" select="$version-subdir-name" tunnel="true"/>
          <xsl:with-param name="version-id" as="xs:string" select="$version-id" tunnel="true"/>
        </xsl:apply-templates>

        <xsl:comment> == END VERSION {$version-name} ({$version-id}) == </xsl:comment>
      </xsl:when>

      <xsl:otherwise>
        <xsl:comment> == NO STEPS FOR VERSION {$version-name} ({$version-id}) == </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:step">
    <xsl:param name="version-subdir-name" as="xs:string" required="true" tunnel="true"/>
    <xsl:param name="version-id" as="xs:string" required="true" tunnel="true"/>

    <xsl:variable name="step-name" as="xs:string" select="xs:string(@name)"/>
    <xsl:variable name="step-id" as="xs:string" select="xs:string(@id)"/>

    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="xtlc:href-concat(($version-subdir-name, $step-name || '.html'))"/>
      <xsl:with-param name="title" select="'STEP p:' || $step-name"/>
      <xsl:with-param name="version-id" select="$version-id"/>
      <xsl:with-param name="content">
        <db:para>TBD</db:para>
        <db:sect1>
          <db:title>SIGNATURE</db:title>
          <db:para>TBD</db:para>
        </db:sect1>
        <db:sect1>
          <db:title>SUMMARY</db:title>
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="xpref:summary"/>
          </xsl:call-template>
        </db:sect1>
        <db:sect1>
          <db:title>DESCRIPTION</db:title>
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="xpref:description"/>
          </xsl:call-template>
        </db:sect1>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- CREATE DOCBOOK ARTICLES: -->

  <xsl:template name="create-docbook-article">
    <!-- Creates a DocBook article inside a xtpxlib container document. -->
    <xsl:param name="href-target" as="xs:string" required="true"/>
    <xsl:param name="version-id" as="xs:string?" required="false" select="()"/>
    <xsl:param name="title" as="xs:string" required="true"/>
    <xsl:param name="content" as="node()*" required="true"/>

    <!-- Remark: We set the content type to text/html, although it isn't yet XHTML. But it will very soon be... -->
    <xtlcon:document href-target="{$href-target}"  content-type="text/html">
      <xsl:if test="exists($version-id)">
        <xsl:attribute name="version-id" select="$version-id"/>
      </xsl:if>
      <db:article>
        <db:info>
          <db:title>{$title}</db:title>
        </db:info>
        <xsl:copy-of select="$content"/>
      </db:article>
    </xtlcon:document>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- PROCESS TEXT: -->

  <xsl:template name="process-text">
    <xsl:param name="surrounding-elm" as="element()" required="false" select="."/>
    <xsl:apply-templates mode="mode-process-text" select="$surrounding-elm/node()"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[normalize-space(.) ne '']" mode="mode-process-text">
    <!-- This is text at the main level, surround it with Markdown markers: -->
    <xdoc:MARKDOWN>
      <xsl:copy/>
    </xdoc:MARKDOWN>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="mode-process-text">
    <!-- An element at top level. This element and its children must be converted to DocBook, but carefully! -->
    <xsl:apply-templates mode="mode-process-text-inner-elements" select="."/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" priority="-1000" mode="mode-process-text">
    <!-- Discard anything else at top level. -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="mode-process-text-inner-elements">
    <xsl:element name="db:{local-name(.)}">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()" mode="mode-process-text-inner-elements">
    <!-- Discard... -->
  </xsl:template>

</xsl:stylesheet>
