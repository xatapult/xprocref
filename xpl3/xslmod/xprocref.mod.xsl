<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rfp_2dj_5bc" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Some shared definitions for the stylesheets in XProcRef.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>
  
  <xsl:mode name="local:mode-remove-unused-namespaces" on-no-match="shallow-copy"/>

  <!-- ======================================================================= -->
  <!-- GENERIC: -->

  <xsl:variable name="xpref:page-extension" as="xs:string" select="'html'"/>

  <xsl:variable name="xpref:default-namespace-prefix" as="xs:string" select="'p'"/>
  
  <xsl:variable name="xpref:max-section-level" as="xs:integer" select="3"/>

  <xsl:variable name="xpref:standard-serialization" as="map(*)" select="map{'indent': true(), 'omit-xml-declaration': true()}"/>

  <!-- ======================================================================= -->
  <!-- PAGE NAMES: -->

  <!-- Main pages: -->
  <xsl:variable name="xpref:name-home-page" as="xs:string" select="'index.' || $xpref:page-extension"/>
  <xsl:variable name="xpref:name-versions-overview-page" as="xs:string" select="'versions.' || $xpref:page-extension"/>
  <xsl:variable name="xpref:name-about-page" as="xs:string" select="'about.' || $xpref:page-extension"/>

  <!-- Pages within a specific version (will be in a subdirectory for this version): -->
  <xsl:variable name="xpref:name-version-home-page" as="xs:string" select="$xpref:name-home-page"/>
  <xsl:variable name="xpref:name-categories-overview-page" as="xs:string" select="'categories.' || $xpref:page-extension"/>
  <xsl:variable name="xpref:name-error-codes-overview-page" as="xs:string" select="'error-codes.' || $xpref:page-extension"/>
  <xsl:variable name="xpref:name-namespaces-overview-page" as="xs:string" select="'namespaces.' || $xpref:page-extension"/>

  <!-- Types set on the container document elements, so we can find things back when dereferencing references: -->
  <xsl:variable name="xpref:type-step" as="xs:string" select="'step'"/>
  <xsl:variable name="xpref:type-category" as="xs:string" select="'category'"/>

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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xpref:error-code-anchor" as="xs:string">
    <xsl:param name="code" as="xs:string"/>
    <xsl:sequence select="'error-' || $code"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xpref:example-anchor" as="xs:string?">
    <!-- Returns an appropriate id for an example  -->
    <xsl:param name="example-elm" as="element(xpref:example)"/>
    <xsl:if test="exists($example-elm/@id)">
      <xsl:variable name="step-elm" as="element(xpref:step)" select="$example-elm/ancestor::xpref:step"/>
      <xsl:sequence select="xpref:example-anchor($step-elm/@name, $step-elm/@version-idref, $example-elm/@id)"/>
    </xsl:if>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xpref:example-anchor" as="xs:string?">
    <!-- Returns an appropriate id for an example  -->
    <xsl:param name="step-name" as="xs:string"/>
    <xsl:param name="version-id" as="xs:string"/>
    <xsl:param name="example-id" as="xs:string"/>
    <xsl:variable name="step-name-full" as="xs:string"
      select="if (starts-with($step-name, $xpref:default-namespace-prefix || ':')) then $step-name else $xpref:default-namespace-prefix || ':' || $step-name"/>
    <xsl:sequence select="string-join(($step-name-full, $version-id, $example-id), '-') => xtlc:str2id()"/>
  </xsl:function>
  
  <!-- ======================================================================= -->
  
  <xsl:template name="xpref:list-document">
    <xsl:param name="root-elm" as="element()" required="true"/>
    
    <db:programlisting xml:space="preserve"><xsl:value-of select="serialize(xpref:remove-unused-namespaces($root-elm), $xpref:standard-serialization)"/></db:programlisting>
  </xsl:template>
  
  <!-- ======================================================================= -->
  <!-- REMOVE UNUSED NAMESPACES -->
  
  <xsl:function name="xpref:remove-unused-namespaces" as="element()">
    <xsl:param name="in" as="element()"/>
    <xsl:apply-templates select="$in" mode="local:mode-remove-unused-namespaces"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="*" mode="local:mode-remove-unused-namespaces">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
