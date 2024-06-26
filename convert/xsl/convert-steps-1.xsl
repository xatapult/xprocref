<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.xtpxlib.nl/ns/xprocref" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:local="#local.kmh_ty1_wbc" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       First stage in converting the steps from specification into XProcRef format.
       
       Separate the various parts.
       
       Input is the convert-steps container.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-copy-no-namespace" on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="version-idref" as="xs:string" required="true"/>

  <xsl:param name="href-xprocref-schema" as="xs:string" required="true"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="edit-marker" as="xs:string" select="'[EDIT]'"/>

  <xsl:variable name="step-group-name" as="xs:string" select="xs:string(/*/@name)"/>
  <xsl:variable name="step-group-id" as="xs:string"
    select="$step-group-name => normalize-space() => xtlc:str2id() => replace('_', '-') => lower-case()"/>

  <xsl:variable name="macrodef-step-group-baselink" as="xs:string" select="'BASELINK-' || upper-case($step-group-id)">
    <!-- This is the name of a supposed macrodef in the final step specification. You have to make sure it is there! -->
  </xsl:variable>

  <xsl:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target-path)"/>
  <xsl:variable name="href-xprocref-schema-rel" as="xs:string" select="xtlc:href-relative-from-path($href-target, $href-xprocref-schema)"/>

  <!-- ================================================================== -->

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:attribute name="group-id" select="$step-group-id"/>
      <xsl:attribute name="href-schema" select="$href-xprocref-schema"/>
      <xsl:attribute name="href-schema-rel" select="$href-xprocref-schema-rel"/>
      <xsl:attribute name="macrodef-step-group-baselink" select="$macrodef-step-group-baselink"/>
      <xsl:attribute name="version-idref" select="$version-idref"/>
      <xsl:attribute name="edit-marker" select="$edit-marker"/>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlcon:document[@type eq 'step']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <!-- Pre-flight check: -->
      <xsl:if test="empty(db:section)">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Document does not contain a section: ', .)"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:apply-templates select="db:section[1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:section">

    <xsl:variable name="step-specification-id" as="xs:string" select="xs:string(@xml:id)"/>
    <xsl:variable name="step-title" as="xs:string" select="xs:string(db:title[1])"/>
    <xsl:variable name="step-name" as="xs:string" select="substring-after($step-title, ':')"/>

    <xsl:message> * {$step-name}</xsl:message>
    <xsl:if test="not(starts-with($step-title, 'p:'))">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Step name does not start with p: ', xtlc:q($step-title))"/>
      </xsl:call-template>
    </xsl:if>

    <step name="{$step-name}" version-idref="{$version-idref}" category-idrefs="{$step-group-id}" short-description="{$edit-marker} {$step-name} short description">
      <xsl:attribute name="xsi:schemaLocation" select="'http://www.xtpxlib.nl/ns/xprocref ' || $href-xprocref-schema-rel"/>

      <specification-link>
        <xsl:attribute name="href" select="'{$' || $macrodef-step-group-baselink || '}#' || $step-specification-id"/>
      </specification-link>

      <signature>
        <xsl:call-template name="copy-no-namespace">
          <xsl:with-param name="elms" select="p:declare-step[1]/*"/>
        </xsl:call-template>
      </signature>

      <summary>
        <!-- The summary is everything that comes before the <p:declare-step> element: -->
        <para>{$edit-marker}</para>
        <xsl:for-each-group select="* except db:title" group-adjacent="exists(self::p:declare-step)">
          <xsl:if test="(position() eq 1) and not(current-grouping-key())">
            <xsl:call-template name="copy-no-namespace">
              <xsl:with-param name="elms" select="current-group()"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each-group>
      </summary>

      <description>
        <!-- The description is everything that comes after the first <p:declare-step> element -->
        <para>{$edit-marker}</para>
        <xsl:for-each-group select="* except db:title" group-adjacent="exists(self::p:declare-step)">
          <xsl:if test="(position() gt 1) and not(current-grouping-key())">
            <xsl:call-template name="copy-no-namespace">
              <xsl:with-param name="elms" select="current-group()"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each-group>
      </description>

    </step>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- COPY WITHOUT NAMESPACE: -->

  <xsl:template name="copy-no-namespace">
    <xsl:param name="elms" as="element()*" required="false" select="."/>
    <xsl:apply-templates select="$elms" mode="mode-copy-no-namespace"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="mode-copy-no-namespace">
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
