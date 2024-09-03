<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.w4q_rkr_ncc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0" exclude-inline-prefixes="#all" name="create-version-step-identities">

  <p:documentation>
    Creates step-identity elements from all steps defined for a version.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation> </p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <!-- Make sure these directories end with a / ! -->
  <p:option name="href-steps-in" as="xs:string" required="false" select="resolve-uri('../src/3.0/standard-steps/', static-base-uri())"/>
  <p:option name="href-step-identities-out" as="xs:string" required="false" select="resolve-uri('../src/3.1/standard-steps/', static-base-uri())"/>

  <!-- The version id we're creating the identities for: -->
  <p:option name="identity-version-idref" as="xs:string" required="false" select="'v31'"/>

  <!-- The baselink macro for the version we're creating the identities for: -->
  <p:option name="identity-version-baselink-macro-name" as="xs:string" required="false" select="'BASELINK-STANDARD-STEPS-V31'"/>
  
  <!-- Schema location string: -->
  <p:option name="schema-location" as="xs:string" required="false" select="'http://www.xtpxlib.nl/ns/xprocref ../../../xsd/xprocref.xsd'"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:directory-list path="{$href-steps-in}"/>

  <p:for-each>
    <p:with-input select="/*/c:file"/>
    <p:variable name="filename" as="xs:string" select="xs:string(/*/@name)"/>
    <p:variable name="href-in" as="xs:string" select="$href-steps-in || $filename"/>
    <p:variable name="href-out" as="xs:string" select="$href-step-identities-out || $filename"/>

    <p:load href="{$href-in}"/>
    <p:variable name="step-name" as="xs:string" select="xs:string(/*/@name)"/>
    <p:variable name="step-base-version" as="xs:string" select="xs:string(/*/@version-idref)"/>
    <p:variable name="step-specref" as="xs:string" select="xs:string(/*/@href-specification)"/>

    <!-- WARNING: This is a bit of a hack, but sufficient for now. Assumes a specification href is like this:
      href-specification="{$BASELINK-STANDARD-STEPS-V30}#c.count" -->
    <p:variable name="link-suffix" as="xs:string" select="substring-after($step-specref, '}')"/>
    <p:variable name="full-specification-link" as="xs:string" select="'{$' || $identity-version-baselink-macro-name || '}' || $link-suffix"/>

    <p:identity>
      <p:with-input>
        <step-identity xmlns="http://www.xtpxlib.nl/ns/xprocref" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="{$step-name}"
          base-version-idref="{$step-base-version}" version-idref="{$identity-version-idref}" href-specification="{$full-specification-link}"
          xsi:schemaLocation="{$schema-location}"/>
      </p:with-input>
    </p:identity>

    <p:store href="{$href-out}" serialization="map{'method': 'xml', 'indent': true()}" name="identity-store"/>
    <p:identity>
      <p:with-input pipe="result-uri@identity-store"/>
    </p:identity>

  </p:for-each>

  <p:wrap-sequence wrapper="identities-written"/>
  <p:add-attribute attribute-name="timestamp" attribute-value="{current-dateTime()}"/>

</p:declare-step>
