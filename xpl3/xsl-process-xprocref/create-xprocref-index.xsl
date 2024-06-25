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

  <xsl:variable name="add-comments" as="xs:boolean" select="false()" static="true"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="doc" as="document-node()" select="/"/>

  <xsl:variable name="version-elements" as="element(xpref:version)*" select="$doc/*/xpref:versions/xpref:version"/>
  <xsl:variable name="step-elements" as="element(xpref:step)*" select="$doc/*/xpref:steps/xpref:step"/>
  <xsl:variable name="category-elements" as="element(xpref:category)*" select="$doc/*/xpref:categories/xpref:category"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xprocref-index>
      <xsl:attribute name="timestamp" select="current-dateTime()" use-when="$add-comments"/>

      <!-- Base info for all categories: -->
      <!--<xsl:comment use-when="$add-comments"> == ALL CATEGORIES: == </xsl:comment>
      <xsl:apply-templates select="$category-elements">
        <xsl:sort select="local:sort-key-category(.)"/>
      </xsl:apply-templates>-->

      <!-- Base info for the steps: -->
      <!--<xsl:comment use-when="$add-comments"> == ALL STEPS: == </xsl:comment>
      <xsl:apply-templates select="$step-elements">
        <xsl:sort select="local:sort-key-step(.)"/>
      </xsl:apply-templates>-->

      <!-- Further organization per version: -->
      <xsl:comment use-when="$add-comments"> == ALL VERSIONS: == </xsl:comment>
      <xsl:apply-templates select="$version-elements">
        <xsl:sort select="local:sort-key-version(.)"/>
      </xsl:apply-templates>

      <!-- Categories: -->
      <!-- TBD -->

    </xprocref-index>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

 <!-- <xsl:template match="xpref:step">
    <xsl:copy>
      <xsl:apply-templates select="(@id, @name, @short-description)"/>
    </xsl:copy>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!--<xsl:template match="xpref:category">
    <xsl:copy>
      <xsl:apply-templates select="(@* except @primary)"/>
      <xsl:attribute name="primary" select="xtlc:str2bln(@primary, false())"/>
    </xsl:copy>
  </xsl:template>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:version">
    <!-- The version is our main entry. -->
    <xsl:variable name="version-id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="steps-for-version" as="element(xpref:step)*" select="$step-elements[@version-idref eq $version-id]"/>

    <xsl:comment use-when="$add-comments"> == Version {$version-id} == </xsl:comment>
    <!-- Remark: We add the name of the version because otherwise we couldn't access it in the processing of xhtml-to-page.xsl.  -->
    <versionref id="{$version-id}" name="{@name}">

      <!-- Steps for this version: -->
      <xsl:for-each select="$steps-for-version">
        <xsl:sort select="local:sort-key-step(.)"/>
        <xsl:variable name="step-name" as="xs:string" select="xs:string(@name)"/>

        <!-- What steps are in this version? -->
        <xsl:comment use-when="$add-comments"> == Step {$step-name} in version {$version-id} == </xsl:comment>
        <stepref id="{@id}">

          <!-- What categories is this step in? -->
          <xsl:comment use-when="$add-comments"> == Categories for step {$step-name} in version {$version-id} == </xsl:comment>
          <xsl:for-each select="local:get-categories-for-idrefs(@category-idrefs)">
            <xsl:sort select="local:sort-key-category(.)"/>
            <categoryref id="{@id}"/>
          </xsl:for-each>

          <!-- What other version is this step in? -->
          <xsl:variable name="same-named-steps-in-other-versions" as="element(xpref:step)*"
            select="$step-elements[@name eq $step-name][@version-idref ne $version-id]"/>
          <xsl:variable name="other-version-idrefs" as="xs:string*"
            select="($same-named-steps-in-other-versions/@version-idref ! xs:string(.)) => distinct-values()"/>
          <xsl:variable name="other-versions" as="element(xpref:version)*" select="$version-elements[@id = $other-version-idrefs]"/>
          <xsl:comment use-when="$add-comments"> == Other versions for step {$step-name} in version {$version-id} == </xsl:comment>
          <xsl:for-each select="$other-versions">
            <xsl:sort select="local:sort-key-version(.)"/>
            <other-versionref id="{@id}"/>
          </xsl:for-each>

        </stepref>
      </xsl:for-each>

      <!-- Categories for this version -->
      <xsl:variable name="category-ids-for-version" as="xs:string*"
        select="(for $step in $steps-for-version return xtlc:str2seq($step/@category-idrefs)) => distinct-values()"/>
      <xsl:variable name="categories-for-version" as="element(xpref:category)*"
        select="local:get-categories-for-idrefs-sequence($category-ids-for-version)"/>
      <xsl:comment use-when="$add-comments"> == All categories for version {$version-id}: == </xsl:comment>
      <xsl:for-each select="$categories-for-version">
        <xsl:sort select="local:sort-key-category(.)"/>
        <xsl:variable name="category-id" as="xs:string" select="xs:string(@id)"/>
        <categoryref id="{$category-id}">
          <!-- Get all the steps in this category: -->
          <xsl:variable name="steps-in-category" as="element(xpref:step)*" select="$steps-for-version[$category-id = xtlc:str2seq(@category-idrefs)]"/>
          <xsl:for-each select="$steps-in-category">
            <xsl:sort select="local:sort-key-step(.)"/>
            <stepref id="{@id}"/>
          </xsl:for-each>
        </categoryref>
      </xsl:for-each>
    </versionref>

  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:function name="local:get-categories-for-idrefs-sequence" as="element(xpref:category)*">
    <xsl:param name="idrefs" as="xs:string*"/>
    <xsl:sequence select="$category-elements[@id = $idrefs]"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-categories-for-idrefs" as="element(xpref:category)*">
    <xsl:param name="idrefs" as="xs:string"/>
    <xsl:sequence select="local:get-categories-for-idrefs-sequence(xtlc:str2seq($idrefs))"/>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- SORTING FUNCTIONS: -->

  <xsl:function name="local:sort-key-version" as="xs:integer">
    <!-- Must be sorted in document order. First one should be the current one. -->
    <xsl:param name="version-elm" as="element(xpref:version)"/>
    <xsl:sequence select="count($version-elm/preceding-sibling::xpref:version)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:sort-key-step" as="xs:string">
    <xsl:param name="step-elm" as="element(xpref:step)"/>
    <xsl:sequence select="lower-case($step-elm/@name)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:sort-key-category" as="xs:string">
    <xsl:param name="category-elm" as="element(xpref:category)"/>
    <xsl:variable name="is-primary" as="xs:boolean" select="xtlc:str2bln($category-elm/@primary, false())"/>
    <xsl:sequence select="(if ($is-primary) then '!' else ()) || lower-case($category-elm/@name)"/>
    <!-- Suffixing a ! makes it come first. -->
  </xsl:function>

</xsl:stylesheet>
