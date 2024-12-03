<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xvk_rt1_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:db="http://docbook.org/ns/docbook" version="3.0" exclude-inline-prefixes="#all" name="convert-required-steps">

  <p:documentation>
    Converts additional steps into XProcRef format. For these steps, all are in their own file.
    
    IMPORTANT: This is intended as a one-time action. After this, the result must be hand-edited.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="convert-steps.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A report thingy</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="name" as="xs:string" required="false" select="'ixml'"/>

  <p:option name="href-source" as="xs:string" required="false"
    select="'file:/C:/Data/Erik/work/xproc-3/3.0-steps/step-'|| $name || '/src/main/xml/specification.xml'">
    <p:documentation>The additional steps source document.</p:documentation>
  </p:option>

  <p:option name="href-build" as="xs:string" required="false" select="resolve-uri('../build/converted-' || $name || '-steps', static-base-uri())">
    <p:documentation>URI where the results will be write. Watch out: *never* overwrite any, possibly already edited, real sources!</p:documentation>
  </p:option>

  <p:option name="version-idref" as="xs:string" required="false" select="'v30'"/>
  <p:option name="specification-baselink" as="xs:string" required="false" select="'https://spec.xproc.org/master/head/' || $name || '/'"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:load href="{$href-source}"/>

  <!-- Get everything we need in a container structure: -->
  <p:for-each>
    <p:with-input select="//db:section[@xml:id eq 'library']/db:section"/>
    <p:variable name="href-rel" as="xs:string" select="substring-after(/*/db:title, 'p:') || '.xml'"/>
    
    <p:wrap match="/*" wrapper="xtlcon:document"/>
    <p:add-attribute attribute-name="href-source" attribute-value="{$href-rel}"/>
    <p:add-attribute attribute-name="type" attribute-value="step"/>
  </p:for-each>

  <p:wrap-sequence wrapper="xtlcon:document-container"/>
  <p:add-attribute attribute-name="timestamp" attribute-value="{current-dateTime()}"/>
  <p:add-attribute attribute-name="href-target-path" attribute-value="{$href-build}"/>
  <p:add-attribute attribute-name="name" attribute-value="{$name} steps"/>
  <p:add-attribute attribute-name="specification-baselink" attribute-value="{$specification-baselink}"/>

  <!-- Convert it: -->
  <xpref:convert-steps steps-required="false">
    <p:with-option name="version-idref" select="$version-idref"/>
  </xpref:convert-steps>

</p:declare-step>
