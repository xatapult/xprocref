<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="process-xprocref" type="xpref:process-xprocref">

  <p:documentation>
    TBD 
    Processes an XProcRef specification into a website.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/validate/validate.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/expand-macro-definitions/expand-macro-definitions.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>

  <p:import href="../../xtpxlib-xdoc/xpl3mod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The main XProcRef specification to process</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>Some report thingie.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-build-location" as="xs:string" required="false" select="resolve-uri('../build', static-base-uri())">
    <p:documentation>The location where the website is built.</p:documentation>
  </p:option>

  <p:option name="href-web-resources" as="xs:string" required="false" select="resolve-uri('../web-resources', static-base-uri())">
    <p:documentation>Directory with web-resources (like CSS, JavaScript, etc.). All sub-directories underneath this directory are 
      copied verbatim to the build location.</p:documentation>
  </p:option>

  <!-- ======================================================================= -->
  <!-- SUBSTEPS: -->

  <p:declare-step type="local:copy-web-resources" name="copy-web-resources">
    <!-- Copies the web resources to the appropriate location on the website. Acts as an identity step. -->

    <p:import href="../../xtpxlib-common/xpl3mod/subdir-list/subdir-list.xpl"/>
    <p:import href="../../xtpxlib-common/xpl3mod/copy-dir/copy-dir.xpl"/>

    <p:input port="source" primary="true" sequence="true" content-types="any"/>
    <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@copy-web-resources"/>

    <p:option name="href-web-resources" as="xs:string" required="true"/>
    <p:option name="href-build-location" as="xs:string" required="true"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xtlc:subdir-list path="{$href-web-resources}"/>
    <p:for-each>
      <p:with-input select="/*/subdir"/>
      <p:variable name="source-dir" as="xs:string" select="/*/@href"/>
      <p:variable name="target-dir" as="xs:string" select="string-join(($href-build-location, /*/@name), '/')"/>
      <xtlc:copy-dir href-source="{$source-dir}" href-target="{$target-dir}"/>
    </p:for-each>

  </p:declare-step>

  <!-- ======================================================================= -->
  <!-- GLOBAL SETTINGS: -->

  <p:variable name="xprocref-base-uri" as="xs:string" select="base-uri(/)"/>

  <p:variable name="href-xprocref-schema" as="xs:string" select="resolve-uri('../xsd/xprocref.xsd', static-base-uri())"/>
  <p:variable name="href-xprocref-schematron" as="xs:string" select="resolve-uri('../sch/xprocref.sch', static-base-uri())"/>


  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:identity message="* XProcRef processing"/>
  <p:identity message="  * Source document: {$xprocref-base-uri}"/>
  <p:identity message="  * Build location: {$href-build-location}"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Preparations: -->

  <!-- Process any XIncludes and record the original base URI on the root: -->
  <p:xinclude fixup-xml-base="true"/>
  <p:add-xml-base relative="false"/>

  <!-- Delete schema references (annoying, since they are no longer valid): -->
  <p:delete match="@xsi:*"/>
  <p:namespace-delete prefixes="xsi"/>
  <p:delete match="processing-instruction(xml-model)"/>

  <!-- Expand any macros: -->
  <xtlc:expand-macro-definitions/>

  <!-- Validate: -->
  <xtlc:validate>
    <p:with-option name="href-schema" select="$href-xprocref-schema"/>
    <p:with-option name="href-schematron" select="$href-xprocref-schematron"/>
  </xtlc:validate>

  <!-- Copy the web resources: -->
  <local:copy-web-resources p:message="  * Copying web resources">
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
  </local:copy-web-resources>

  <!-- Take care that all steps are there for all versions: -->
  <!-- TBD -->


  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create container: -->

  <!-- Create a container (all text still in DocBook/Markdown): -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-xcourse/create-xprocref-container.xsl"/>
    <!--<p:with-option name="parameters" select="map{ }"/>-->
  </p:xslt>

  <!-- Process the Markdown (into DocBook): -->
  <xdoc:markdown-to-docbook/>


</p:declare-step>
