<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" name="process-xprocref-to-website" type="xpref:process-xprocref-to-website">

  <p:documentation>
    Processes an XProcRef specification into a website.
    
    This is the main, overarching, pipeline that can, by setting options, do it all! 
    The idea is that this is called from pipelines in ../xpl3/ that use certain settings to 
    get the desired effect (like creating a test version, a limited version, etc.).
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="prepare-xprocref.xpl"/>
  <p:import href="prepared-xprocref-to-website.xpl"/>
  <p:import href="prepared-xprocref-to-pdf.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The main XProcRef specification to process</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report thingie.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- DEBUG SETTINGS -->

  <p:option name="write-intermediate-results" as="xs:boolean" required="false" select="true()"/>
  <p:option name="href-intermediate-results" as="xs:string" required="false" select="resolve-uri('../tmp', static-base-uri())"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS FOR PREPARATIONS: -->

  <p:option name="production-version" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to create a production version . For a production version, all steps with @publish="false" will not appear in the output. 
      A test version will get a warning banner.
    </p:documentation>
  </p:option>

  <p:option name="wip" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to add a warning banner on every page that the site is work in progress.</p:documentation>
  </p:option>

  <p:option name="limit-to-steps" as="xs:string*" required="false" select="()">
    <p:documentation>Limit the output to the steps mentioned here. Use the step names *without* a namespace prefix!</p:documentation>
  </p:option>

  <!-- ======================================================================= -->
  <!-- OPTIONS FOR WEBSITE BUILDING: -->

  <p:option name="href-build-location" as="xs:string" required="false" select="resolve-uri('../build', static-base-uri())">
    <p:documentation>The location where the website is built.</p:documentation>
  </p:option>

  <p:option name="href-web-resources" as="xs:string" required="false" select="resolve-uri('../resources/web', static-base-uri())">
    <p:documentation>Directory with web-resources (like CSS, JavaScript, etc.). All sub-directories underneath this directory are 
      copied verbatim to the build location.</p:documentation>
  </p:option>

  <p:option name="href-web-template" as="xs:string" required="false" select="resolve-uri('../templates/web/default-template.html', static-base-uri())">
    <p:documentation>URI of the web template used to build the pages.</p:documentation>
  </p:option>

  <p:option name="cname" as="xs:string?" required="false" select="'xprocref.org'">
    <p:documentation>The URI under which the pages are published (for GitHub pages). If empty no CNAME entry is created.</p:documentation>
  </p:option>

  <!-- ======================================================================= -->
  <!-- OPTIONS FOR PDF CREATION: -->

  <p:option name="build-pdf" as="xs:boolean" required="false" select="$production-version">
    <p:documentation>Whether to also add a PDF to the site (might be turned off for testing purposes).</p:documentation>
  </p:option>

  <!-- ======================================================================= -->

  <p:variable name="start-timestamp" as="xs:dateTime" select="current-dateTime()"/>

  <p:variable name="xprocref-base-uri" as="xs:string" select="p:document-property(., 'base-uri')"/>
  <p:identity message="* XProcRef to website processing"/>
  <p:identity message="  * Source document: {$xprocref-base-uri}"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create the website: -->

  <xpref:prepare-xprocref>
    <p:with-input pipe="source@process-xprocref-to-website"/>
    <p:with-option name="prompt" select="'Preparations for building website:'"/>
    <p:with-option name="write-intermediate-results" select="$write-intermediate-results"/>
    <p:with-option name="href-intermediate-results" select="$href-intermediate-results"/>
    <p:with-option name="production-version" select="$production-version"/>
    <p:with-option name="wip" select="$wip"/>
    <p:with-option name="limit-to-steps" select="$limit-to-steps"/>
    <p:with-option name="limit-to-latest-version" select="false()"/>
  </xpref:prepare-xprocref>

  <xpref:prepared-xprocref-to-website>
    <p:with-option name="write-intermediate-results" select="$write-intermediate-results"/>
    <p:with-option name="href-intermediate-results" select="$href-intermediate-results"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-web-template" select="$href-web-template"/>
    <p:with-option name="cname" select="$cname"/>
  </xpref:prepared-xprocref-to-website>
  <p:identity name="website-build-result"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create the PDF: -->

  <p:if test="$build-pdf">
    <xpref:prepare-xprocref>
      <p:with-input pipe="source@process-xprocref-to-website"/>
      <p:with-option name="prompt" select="'Preparations for building PDF:'"/>
      <p:with-option name="write-intermediate-results" select="$write-intermediate-results"/>
      <p:with-option name="href-intermediate-results" select="$href-intermediate-results"/>
      <p:with-option name="production-version" select="$production-version"/>
      <p:with-option name="wip" select="$wip"/>
      <p:with-option name="limit-to-steps" select="$limit-to-steps"/>
      <p:with-option name="limit-to-latest-version" select="true()"/>
    </xpref:prepare-xprocref>

    <xpref:prepared-xprocref-to-pdf>
      <p:with-option name="href-pdf" select="$href-build-location || '/resources/xprocref.pdf'"/>
      <p:with-option name="write-intermediate-results" select="$write-intermediate-results"/>
      <p:with-option name="href-intermediate-results" select="$href-intermediate-results"/>
      <p:with-option name="process-for-binding" select="false()"/>
    </xpref:prepared-xprocref-to-pdf>
  </p:if>
  <p:identity name="pdf-build-result"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Done, finalize: -->

  <p:insert position="first-child">
    <p:with-input>
      <process-xprocref-to-website/>
    </p:with-input>
    <p:with-input port="insertion" pipe="@website-build-result"/>
  </p:insert>
  <p:if test="$build-pdf">
    <p:insert position="last-child">
      <p:with-input port="insertion" pipe="@pdf-build-result"/>
    </p:insert>
  </p:if>
  <p:variable name="duration" as="xs:dayTimeDuration" select="current-dateTime() - $start-timestamp"/>
  <p:add-attribute attribute-name="timestamp" attribute-value="{string($start-timestamp)}"/>
  <p:add-attribute attribute-name="duration" attribute-value="{string($duration)}"/>
  <p:variable name="duration-string" as="xs:string"
    select="string($duration) => replace('P', '') => replace('T', ' ') => normalize-space() => lower-case()"/>
  <p:identity message="* XProcRef to website processing done ({$duration-string})"/>

</p:declare-step>
