<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.uvr_fbj_w2c"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" version="3.0" exclude-inline-prefixes="#all">

  <p:import href="../prepare-xprocref.xpl"/>
  <p:import href="../prepared-xprocref-to-pdf.xpl"/>

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../../src/xprocref.src.main.xml"/>
  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>

  <!-- ======================================================================= -->
  
  <xpref:prepare-xprocref limit-to-latest-version="true">
    <!--<p:with-option name="limit-to-steps" as="xs:string*" select="('message', 'identity', 'rename')"/>-->
<!--    <p:with-option name="limit-to-steps" as="xs:string*" select="('archive')"/>-->
  </xpref:prepare-xprocref>
  
<!--  <p:load href="../../tmp/060-xprocref-raw-container-docbook.xml"></p:load>-->

  <xpref:prepared-xprocref-to-pdf>
    <p:with-option name="href-pdf" select="resolve-uri('../../tmp/xprocref.pdf', static-base-uri())"/>
    <p:with-option name="write-intermediate-results" select="true()"/>
    <p:with-option name="href-intermediate-results" select="resolve-uri('../../tmp/', static-base-uri())"/>
  </xpref:prepared-xprocref-to-pdf>

  <p:variable name="empty-map" as="map(*)" select="map{}"/>
  <p:set-properties properties="map{'serialization':  $empty-map}"/>

</p:declare-step>
