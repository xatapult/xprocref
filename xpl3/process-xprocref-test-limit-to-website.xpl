<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.a2b_jkd_5bc"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" version="3.0" exclude-inline-prefixes="#all" name="process-xprocref-test-limit-to-website">

  <p:documentation>
    Produces a test version of the XProcRef site (with all unpublished steps included)
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="process-xprocref-to-website.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../src/xprocref.src.main.xml"/>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>

  <!-- ================================================================== -->

  <p:variable name="limit-to-steps" as="xs:string*" select="('message', 'identity', 'rename')"/>

  <xpref:process-xprocref-to-website production-version="false" wip="false" >
    <p:with-option name="limit-to-steps" select="$limit-to-steps"/>
    <p:with-option name="href-build-location" select="resolve-uri('../build', static-base-uri())"/>
  </xpref:process-xprocref-to-website>

</p:declare-step>
