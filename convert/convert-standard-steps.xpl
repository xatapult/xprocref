<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xvk_rt1_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  version="3.0" exclude-inline-prefixes="#all" name="convert-required-steps">

  <p:documentation>
    Converts all the standard (required) steps into XProcRef format. For these steps, all are in their own file.
    
    IMPORTANT: This is intended as a one-time action. After this, the result must be hand-edited.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>

  <p:import href="convert-steps.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A report thingy</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-sources" as="xs:string" required="false"
    select="resolve-uri('../../../xproc-3/3.0-steps/steps/src/main/xml/steps/', static-base-uri())">
    <p:documentation>The directory where all the step description sources are.</p:documentation>
  </p:option>

  <p:option name="href-build" as="xs:string" required="false" select="resolve-uri('build/standard-steps', static-base-uri())">
    <p:documentation>URI where the results will be write. Watch out: *never* overwrite any, possibly already edited, real sources!</p:documentation>
  </p:option>
  
  <p:option name="version-idref" as="xs:string" required="false" select="'v30'"/>
  <p:option name="specification-baselink" as="xs:string" required="false" select="'https://spec.xproc.org/master/head/steps/'"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Get all the steps on board and create a container structure suitable for the xpref:convert-steps step.  -->
  <xtlc:recursive-directory-list include-filter="\.xml$" depth="1" flatten="true" p:message="* Converting standard steps from {$href-sources}">
    <p:with-option name="path" select="$href-sources"/>
  </xtlc:recursive-directory-list>

  <!-- Load the all and turn them into the required container structure: -->
  <p:for-each>
    <p:with-input select="/c:directory/c:file"/>
    <p:variable name="href-abs" as="xs:string" select="xs:string(/*/@href-abs)"/>
    <p:variable name="href-rel" as="xs:string" select="xs:string(/*/@href-rel)"/>
    <p:load>
      <p:with-option name="href" select="$href-abs"/>
    </p:load>
    <p:wrap match="/*" wrapper="xtlcon:document"/>
    <p:add-attribute attribute-name="href-source" attribute-value="{$href-rel}"/>
    <p:add-attribute attribute-name="type" attribute-value="step"/>
  </p:for-each>

  <p:wrap-sequence wrapper="xtlcon:document-container"/>
  <p:add-attribute attribute-name="timestamp" attribute-value="{current-dateTime()}"/>
  <p:add-attribute attribute-name="href-source-path" attribute-value="{$href-sources}"/>
  <p:add-attribute attribute-name="href-target-path" attribute-value="{$href-build}"/>
  <p:add-attribute attribute-name="name" attribute-value="Standard steps"/>
  <p:add-attribute attribute-name="specification-baselink" attribute-value="{$specification-baselink}"/>

  <!-- Convert it: -->
  <xpref:convert-steps steps-required="true">
    <p:with-option name="version-idref" select="$version-idref"/>
  </xpref:convert-steps>

</p:declare-step>
