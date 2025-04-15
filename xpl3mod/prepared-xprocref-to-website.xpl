<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" name="prepared-xprocref-to-website" type="xpref:prepared-xprocref-to-website">

  <p:documentation>
    Processes a prepared XProcRef xtpxlib container (by prepare-xprocref.xpl) into a website.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>

  <p:import href="../../xtpxlib-xdoc/xpl3/xdoc-to-xhtml.xpl"/>
  <p:import href="../../xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"/>

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

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:identity message="  * Building website:"/>
  <p:identity message="    * Location: {$href-build-location}"/>

  <!-- Get some global information from the container: -->
  <p:variable name="production-version" as="xs:boolean" select="xs:boolean(/*/@production-version)"/>
  <p:variable name="wip" as="xs:boolean" select="xs:boolean(/*/@wip)"/>
  <p:variable name="limit-to-steps" as="xs:string" select="xs:string(/*/@limit-to-steps)"/>
  <p:variable name="limit-to-latest-version" as="xs:string" select="xs:string(/*/@limit-to-latest-version)"/>
  <p:variable name="all-steps-count" as="xs:integer" select="xs:integer(/*/@all-steps-count)"/>
  <p:variable name="processed-steps-count" as="xs:integer" select="xs:integer(/*/@processed-steps-count)"/>
  <p:variable name="xprocref-index" as="element(xpref:xprocref-index)" select="/*/xtlcon:document[@type eq 'index']/xpref:xprocref-index"/>

  <!-- Clean the result directory: -->
  <xtlc:create-clear-directory clear="true">
    <p:with-option name="href-dir" select="$href-build-location"/>
  </xtlc:create-clear-directory>

  <!-- Copy the web resources: -->
  <local:copy-web-resources p:message="    * Copying web resources">
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
  </local:copy-web-resources>

  <!-- Create a CNAME document (for the GitHub pages): -->
  <p:if test="$production-version and exists($cname)">
    <p:store href="{$href-build-location}/CNAME" serialization="map{'method': 'text'}" message="    * CNAME ({$cname})">
      <p:with-input>
        <p:inline xml:space="preserve" content-type="text/plain">{$cname}</p:inline>
      </p:with-input>
    </p:store>
  </p:if>

  <!-- Process the container xdoc into XHTML: -->
  <p:identity>
    <p:with-input pipe="source@prepared-xprocref-to-website"/>
  </p:identity>
  <p:variable name="html-page-count" as="xs:integer" select="count(/*/xtlcon:document[exists(db:article)])"/>
  <p:viewport match="xtlcon:document[exists(db:article)]" message="    * Converting {$html-page-count} pages to HTML">
    <p:if test="(p:iteration-position() mod 10) eq 0">
      <p:identity message="      * Page {p:iteration-position()}/{$html-page-count}"/>
    </p:if>
    <p:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target)"/>
    <p:variable name="keywords" as="xs:string?" select="string(/*/@keywords)[.]"/>
    <p:viewport match="db:article[1]">
      <xdoc:xdoc-to-xhtml add-numbering="false" add-identifiers="false" create-header="false"/>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-website/xhtml-to-page.xsl"/>
        <p:with-option name="parameters"
          select="map{'xprocref-index': $xprocref-index, 'href-template': $href-web-template, 'href-target': $href-target, 'keywords': $keywords}"/>
      </p:xslt>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-website/convert-menu.xsl"/>
      </p:xslt>
    </p:viewport>
  </p:viewport>
  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/100-xprocref-final-container-html.xml"/>
  </p:if>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Finishing: -->

  <!-- Check for any markup errors and report these: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepared-xprocref-to-website/check-for-markup-errors.xsl"/>
  </p:xslt>

  <!-- Write the container to disk: -->
  <xtlcon:container-to-disk remove-target="false" p:message="    * Writing to target">
    <p:with-option name="href-target-path" select="$href-build-location"/>
  </xtlcon:container-to-disk>

  <p:identity>
    <p:with-input>
      <xprocref-to-website build-location="{$href-build-location}" production-version="{$production-version}" wip="{$wip}"
        limit-to-steps="{$limit-to-steps}" limit-to-latest-version="{$limit-to-latest-version}"/>
    </p:with-input>
  </p:identity>

</p:declare-step>
