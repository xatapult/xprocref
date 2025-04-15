<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ifz_nyz_z2c"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" version="3.0" exclude-inline-prefixes="#all" name="proces-xprocref-to-book-pdf">

  <p:documentation>
    Takes the most current XProcRef sources and processes these into a PDF for a book.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../xpl3mod/prepare-xprocref.xpl"/>
  <p:import href="../xpl3mod/prepared-xprocref-to-pdf.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../src/xprocref.src.main.xml">
    <p:documentation>The XProcRef main source.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>Some report XML.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-pdf" as="xs:string" required="false" select="resolve-uri('../pdf/xprocref-book.pdf', static-base-uri())">
    <p:documentation>URI of the resulting PDF.</p:documentation>
  </p:option>


  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Create the book: -->
  <xpref:prepare-xprocref limit-to-latest-version="true"/>

  <xpref:prepared-xprocref-to-pdf process-for-binding="true">
    <p:with-option name="href-pdf" select="$href-pdf"/>
  </xpref:prepared-xprocref-to-pdf>

  <!-- Kill any serialization: -->
  <p:variable name="empty-map" as="map(*)" select="map{}"/>
  <p:set-properties properties="map{'serialization':  $empty-map}"/>

</p:declare-step>
