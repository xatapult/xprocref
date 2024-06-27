<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.acq_h3j_5bc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Converts the raw XProcRef XHTML into a full page. 
       
       Input is the raw XHTML produced by xdoc-to-xhtml.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-process-template" on-no-match="shallow-copy"/>
  <xsl:mode name="mode-process-page-contents" on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-template" as="xs:string" required="true"/>
  <xsl:param name="href-target" as="xs:string" required="true"/>

  <xsl:param name="xprocref-index" as="document-node()" required="true"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="page-contents" as="element()" select="/*"/>

  <xsl:variable name="title-elm" as="element(xhtml:h1)" select="(//xhtml:h1)[1]"/>

  <xsl:variable name="distance-to-homedir" as="xs:integer" select="(tokenize($href-target, '/')[.] => count()) - 1"/>
  <xsl:variable name="homedir-path" as="xs:string" select="(for $p in (1 to $distance-to-homedir) return '../') => string-join()"/>

  <xsl:variable name="homedir-macro" as="xs:string" select="'$HOMEDIR$'"/>
  <xsl:variable name="homedir-macro-regexp" as="xs:string" select="xtlc:str2regexp($homedir-macro)"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:variable name="latest-version-versionref-elm" as="element(xpref:versionref)" select="($xprocref-index/*/xpref:versionref)[1]"/>
  <xsl:variable name="last-version-name" as="xs:string" select="xs:string($latest-version-versionref-elm/@name)"/>

  <!-- ======================================================================= -->

  <xsl:template match="/">
    <!-- We process it all based on the template: -->
    <xsl:if test="not(doc-available($href-template))">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Web template not found: ', xtlc:q($href-template))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="doc($href-template)" mode="mode-process-template"/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- PROCESS TEMPLATE: -->

  <xsl:template match="@*[contains(., $homedir-macro)]" mode="mode-process-template">
    <xsl:attribute name="{node-name(.)}" select="replace(., $homedir-macro-regexp, $homedir-path)"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:TITLE" mode="mode-process-template">
    <xsl:value-of select="normalize-space($title-elm)"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:PAGE-CONTENTS" mode="mode-process-template">
    <xsl:apply-templates select="$page-contents" mode="mode-process-page-contents"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:MENU" mode="mode-process-template">
    <menu xmlns="http://www.xtpxlib.nl/ns/xprocref">
      <menu-entry caption="home" href="{xpref:href-combine($homedir-path, (), $xpref:name-home-page)}"/>
      <menu-entry caption="categories" href="{xpref:href-combine($homedir-path, $last-version-name, $xpref:name-categories-overview-page)}"/>
      <menu-entry caption="info">
        <submenu-entry caption="versions" href="{xpref:href-combine($homedir-path, (), $xpref:name-versions-overview-page)}"/>
        <submenu-entry caption="error codes" href="{xpref:href-combine($homedir-path, (), $xpref:name-error-codes-overview-page)}"/>
        <submenu-entry caption="namespaces" href="{xpref:href-combine($homedir-path, (), $xpref:name-namespaces-overview-page)}"/>
      </menu-entry>
      <menu-entry caption="about" href="{xpref:href-combine($homedir-path, (), $xpref:name-about-page)}"/>
    </menu>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- PROCESS PAGE CONTENTS: -->

  <xsl:template match="xhtml:div[@class eq 'article']" mode="mode-process-page-contents">
    <!-- Root, unwrap. -->
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:div[@class eq 'header']" mode="mode-process-page-contents">
    <!-- DocBook header info, discard. -->
  </xsl:template>

  <xsl:template match="comment()[normalize-space(.) eq '']" mode="mode-process-page-contents">
    <!-- Keep empty comments. These are there for a reason (some head elements need contents, somehow, weird html rules :( -->
    <xsl:copy/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- SUPPORT: -->

  <xsl:template match="comment() | processing-instruction()" mode="#all" priority="-1000">
    <!-- Discard... -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[normalize-space(.) eq '']" priority="-1000" mode="#all">
    <!-- Discard empty text nodes to make the result more compact (can we get away with this?) -->
  </xsl:template>


</xsl:stylesheet>
