<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rfp_2dj_5bc"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  exclude-result-prefixes="#all" expand-text="true">
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

  <xsl:variable name="xpref:error-start-marker" as="xs:string" select="'[***'"/>
  <xsl:variable name="xpref:error-end-marker" as="xs:string" select="']'"/>

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

  <xsl:template name="xpref:markup-error">
    <xsl:param name="error-text" as="xs:string" required="true"/>
    <db:emphasis role="bold">{$xpref:error-start-marker} {$error-text}{$xpref:error-end-marker}</db:emphasis>
  </xsl:template>

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
    <xsl:param name="preserve-space" as="xs:boolean" required="false" select="false()">
      <!-- This will attempt to keep the whitespace (empty lines!). The effect is, unfortunately, also that any 
        existing xml:space="preserve" element is removed... -->
    </xsl:param>
    <xsl:param name="keep-namespace-prefixes" as="xs:string*" required="false" select="()"/>

    <xsl:variable name="contents" as="xs:string">
      <xsl:choose>
        <xsl:when test="exists($root-elm/self::xpref:TEXT)">
          <!-- This is text contents -->
          <xsl:sequence select="string($root-elm)"/>
        </xsl:when>
        <xsl:when test="$preserve-space">
          <!-- When preserving space, we add an xml:space="preserve" attribute and remove it later, as a string! -->
          <xsl:variable name="root-elm-whitespace-preserve" as="element()">
            <xsl:for-each select="$root-elm">
              <xsl:copy>
                <xsl:attribute name="xml:space" select="'preserve'"/>
                <xsl:copy-of select="@* | node()"/>
              </xsl:copy>
            </xsl:for-each>
          </xsl:variable>
          <xsl:sequence
            select="serialize(xpref:remove-unused-namespaces($root-elm-whitespace-preserve, $keep-namespace-prefixes), $xpref:standard-serialization) => replace('\s+xml:space=[&quot;'']preserve[&quot;'']\s+', ' ')"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="serialize(xpref:remove-unused-namespaces($root-elm), $xpref:standard-serialization)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <db:programlisting xml:space="preserve"><xsl:value-of select="$contents"/></db:programlisting>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- REMOVE UNUSED NAMESPACES -->

  <xsl:function name="xpref:remove-unused-namespaces" as="element()">
    <xsl:param name="in" as="element()"/>
    <xsl:param name="keep-namespace-prefixes" as="xs:string*"/>
    <xsl:apply-templates select="$in" mode="local:mode-remove-unused-namespaces">
      <xsl:with-param name="keep-namespace-prefixes" as="xs:string*" select="$keep-namespace-prefixes" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xpref:remove-unused-namespaces" as="element()">
    <xsl:param name="in" as="element()"/>
    <xsl:sequence select="xpref:remove-unused-namespaces($in, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="local:mode-remove-unused-namespaces">
    <xsl:param name="keep-namespace-prefixes" as="xs:string*" required="true" tunnel="true"/>

    <xsl:variable name="elm" as="element()" select="."/>
    <xsl:copy copy-namespaces="false">
      <!-- Re-add the namespaces we have to keep (if any): -->
      <xsl:for-each select="$keep-namespace-prefixes">
        <xsl:variable name="namespace-prefix" as="xs:string" select="."/>
        <xsl:variable name="namespace" as="xs:string?" select="xs:string(namespace-uri-for-prefix($namespace-prefix, $elm))"/>
        <xsl:if test="exists($namespace)">
          <xsl:namespace name="{$namespace-prefix}" select="$namespace"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
