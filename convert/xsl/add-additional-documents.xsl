<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.qfw_2lb_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns="http://www.xtpxlib.nl/ns/xprocref" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Adds additional documents to the container:
       * A <step-group> file which XIncludes all steps
       * A test full XProcRef specification
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="group-name" as="xs:string" select="xs:string(/*/@name)"/>
  <xsl:variable name="group-id" as="xs:string" select="xs:string(/*/@group-id)"/>
  <xsl:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target-path)"/>
  <xsl:variable name="href-schema-rel" as="xs:string" select="xs:string(/*/@href-schema-rel)"/>
  <xsl:variable name="macrodef-step-group-baselink" as="xs:string" select="/*/@macrodef-step-group-baselink"/>
  <xsl:variable name="specification-baselink" as="xs:string" select="xs:string(/*/@specification-baselink)"/>
  <xsl:variable name="version-idref" as="xs:string" select="xs:string(/*/@version-idref)"/>

  <xsl:variable name="href-main-pipeline" as="xs:string"
    select="resolve-uri('../../xpl3/process-xprocref.xpl', static-base-uri()) => xtlc:href-canonical()"/>

  <!-- ======================================================================= -->

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      
      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Errors (in a separate document)-->
      
      <xsl:variable name="href-errors-document" as="xs:string" select="$group-id || '.errors.xml'"/>
      <xtlcon:document href-target="{$href-errors-document}">
        <errors>
          <xsl:attribute name="xsi:schemaLocation" select="'http://www.xtpxlib.nl/ns/xprocref ' || $href-schema-rel"/>
          <xsl:comment> == Errors for: {$group-name} == </xsl:comment>
          
          <xsl:variable name="all-errors" as="element(xpref:step-error)*" select="//xpref:step-error"/>
          <xsl:for-each-group select="$all-errors" group-by="xs:string(@code)">
            <xsl:sort select="current-grouping-key()"></xsl:sort>
            <xsl:variable name="code" as="xs:string" select="current-grouping-key()"/>
            <error code="{$code}">
              <xsl:comment> == {local:step-name-for-step-error(current-group()[1])} == </xsl:comment>
              <xsl:copy-of select="current-group()[1]/xpref:description"/>
              <!-- We add all other descriptions, so we can check whether there is much difference.  -->
              <xsl:for-each select="current-group()[position() gt 1]">
                <xsl:comment> == {local:step-name-for-step-error(.)} - {normalize-space(xpref:description)} == </xsl:comment>
              </xsl:for-each>
            </error>
          </xsl:for-each-group>
        </errors>
      </xtlcon:document>
      
      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Document that XIncludes everything: -->

      <xsl:variable name="href-stepgroup-document" as="xs:string" select="$group-id || '.stepgroup.xml'"/>
      <xtlcon:document href-target="{$href-stepgroup-document}">
        <step-group xmlns:xi="http://www.w3.org/2001/XInclude">
          <xsl:attribute name="xsi:schemaLocation" select="'http://www.xtpxlib.nl/ns/xprocref ' || $href-schema-rel"/>
          <xsl:comment> == Step group for: {$group-name} == </xsl:comment>
          <xsl:for-each select="/*/xtlcon:document[@type eq 'step'][exists(@href-target)]">
            <xi:include href="{@href-target}"/>
          </xsl:for-each>
        </step-group>
      </xtlcon:document>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Test XProcRef specification for these steps: -->

      <xsl:variable name="href-xprocref-document" as="xs:string" select="$group-id || 'test.xprocref.xml'"/>
      <xtlcon:document href-target="{$href-xprocref-document}">
        <xprocref xmlns:xi="http://www.w3.org/2001/XInclude">
          <xsl:attribute name="xsi:schemaLocation" select="'http://www.xtpxlib.nl/ns/xprocref ' || $href-schema-rel"/>
          <xsl:comment> == Test XProcRef document for: {$group-name} == </xsl:comment>

          <macrodefs>
            <macrodef name="{$macrodef-step-group-baselink}" value="{$specification-baselink}"/>
          </macrodefs>

          <namespaces>
            <namespace prefix="p" uri="http://www.w3.org/ns/xproc">
              <description>The main XProc namespace, used for all of its elements, steps and some of its attributes.</description>
            </namespace>
          </namespaces>

          <versions>
            <version id="{$version-idref}" name="{$version-idref}">
              <description>
                <para>Bogus version {$version-idref} for testing group {$group-name}…</para>
              </description>
            </version>
          </versions>
          
          <xi:include href="{$href-errors-document}"/>

          <categories>
            <category id="{$group-id}" name="{$group-name}">
              <description>
                <para>Bogus category for testing group {$group-name}…</para>
              </description>
            </category>
          </categories>

          <steps>
            <xi:include href="{$href-stepgroup-document}"/>
          </steps>

        </xprocref>
      </xtlcon:document>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Test XProc driver: -->

      <xsl:variable name="href-xpldriver-document" as="xs:string" select="$group-id || '.testdriver.xpl'"/>
      <xsl:variable name="href-build-location" as="xs:string" select="xtlc:href-concat(($href-target, 'build'))"/>
      <xtlcon:document href-target="{$href-xpldriver-document}">
        <p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0" exclude-inline-prefixes="#all">

          <p:documentation>XProc XprocRef test driver for: <xsl:value-of select="$group-name"/></p:documentation>

          <p:import href="{$href-main-pipeline}"/>

          <p:input port="source" primary="true" sequence="false" content-types="xml" href="{$href-xprocref-document}"/>
          <p:output port="result" primary="true" sequence="false" content-types="xml"/>

          <xpref:process-xprocref>
            <p:with-option name="href-build-location" select="'{$href-build-location}'"/>
          </xpref:process-xprocref>

        </p:declare-step>
      </xtlcon:document>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    </xsl:copy>

  </xsl:template>
  
  <!-- ======================================================================= -->
  
  <xsl:function name="local:step-name-for-step-error" as="xs:string">
    <xsl:param name="step-error" as="element(xpref:step-error)"/>
    <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-error/ancestor::xpref:step"/>
    <xsl:sequence select="'p:' || $step-elm/@name"/>
  </xsl:function>
  
</xsl:stylesheet>
