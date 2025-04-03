<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" name="prepared-xprocref-to-pdf" type="xpref:prepared-xprocref-to-pdf">

  <p:documentation>
    Processes a prepared XProcRef xtpxlib container (by prepare-xprocref.xpl) into a PDF.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-xdoc/xpl3/xdoc-to-pdf.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The XProcRef xtpxlib container as produced by prepare-xprocref.xpl</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report thingie.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- DEBUG SETTINGS -->

  <p:option name="write-intermediate-results" as="xs:boolean" required="false" select="true()"/>
  <p:option name="href-intermediate-results" as="xs:string" required="false" select="resolve-uri('../tmp', static-base-uri())"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-pdf" as="xs:string" required="true">
    <p:documentation>The URI for the PDF</p:documentation>
  </p:option>

  <!-- ======================================================================= -->

  <p:identity message="  * Building PDF:"/>
  <p:identity message="    * Result URI: {$href-pdf}"/>

  <!-- Pre-flight check: we van only handle a container with a single version in it: -->
  <p:variable name="xprocref-index" as="element(xpref:xprocref-index)"
    select="/xtlcon:document-container/xtlcon:document[@type eq 'index']/xpref:xprocref-index"/>
  <p:variable name="version-element" as="element(xpref:versionref)*" select="$xprocref-index/xpref:versionref"/>
  <p:if test="count($version-element) ne 1">
    <p:error code="xpref:error">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Source prepared container does not contain exactly 1 version (found {count($version-element)})</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  <p:identity message="    * XProc version: {$version-element/@name}"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Preparations: -->

  <p:identity message="    * Preparing source"/>

  <!-- Remove the markup we don't need (it is there for building the website): -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-pdf/clean-prepared-container.xsl"/>
  </p:xslt>

  <!-- Make sure all identifiers and references are ok: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-pdf/fix-identifiers.xsl"/>
  </p:xslt>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-pdf/link-hrefs-to-identifiers.xsl"/>
  </p:xslt>

  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/200-pdf-prepared-container.xml"/>
  </p:if>

  <!-- Turn into a full DocBook/xdoc construction: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-pdf/create-docbook-source.xsl"/>
  </p:xslt>
  
  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/210-pdf-docbook-source.xml"/>
  </p:if>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Turn into PDF -->

  <p:identity message="    * Creating PDF"/>

  <xdoc:xdoc-to-pdf>
    <p:with-option name="href-pdf" select="$href-pdf"/>
    <p:with-option name="href-xsl-fo" select="if ($write-intermediate-results) then ($href-intermediate-results || '/220-pdf-xsl-fo.xml') else ()"/>
  </xdoc:xdoc-to-pdf>

</p:declare-step>
