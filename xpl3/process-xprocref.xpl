<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" name="process-xprocref" type="xpref:process-xprocref">

  <p:documentation>
    TBD 
    Processes an XProcRef specification into a website.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/validate/validate.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/expand-macro-definitions/expand-macro-definitions.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>

  <p:import href="../../xtpxlib-xdoc/xpl3/xdoc-to-xhtml.xpl"/>
  <p:import href="../../xtpxlib-xdoc/xpl3/docbook-to-xhtml.xpl"/>

  <p:import href="../../xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"/>

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
  <!-- DEBUG SETTINGS -->

  <p:option static="true" name="write-intermediate-results" as="xs:boolean" required="false" select="true()"/>
  <p:option static="true" name="href-intermediate-results" as="xs:string" required="false" select="resolve-uri('../tmp', static-base-uri())"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-build-location" as="xs:string" required="false" select="resolve-uri('../build', static-base-uri())">
    <p:documentation>The location where the website is built.</p:documentation>
  </p:option>

  <p:option name="href-web-resources" as="xs:string" required="false" select="resolve-uri('../web-resources', static-base-uri())">
    <p:documentation>Directory with web-resources (like CSS, JavaScript, etc.). All sub-directories underneath this directory are 
      copied verbatim to the build location.</p:documentation>
  </p:option>

  <p:option name="href-web-template" as="xs:string" required="false" select="resolve-uri('../web-templates/default-template.html', static-base-uri())">
    <p:documentation>URI of the web template used to build the pages.</p:documentation>
  </p:option>

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

  <!-- ======================================================================= -->
  <!-- GLOBAL SETTINGS: -->

  <p:variable name="xprocref-base-uri" as="xs:string" select="base-uri(/)"/>

  <p:variable name="href-xprocref-schema" as="xs:string" select="resolve-uri('../xsd/xprocref.xsd', static-base-uri())"/>
  <p:variable name="href-xprocref-schematron" as="xs:string" select="resolve-uri('../sch/xprocref.sch', static-base-uri())"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:variable name="start-timestamp" as="xs:dateTime" select="current-dateTime()"/>

  <p:variable name="limit-to-steps-sequence" as="xs:string"
    select="'(' || string-join(for $s in $limit-to-steps return ('''' || $s || ''''), ', ') || ')'"/>
  <p:variable name="type-string" as="xs:string" select="(if ($production-version) then 'Production' else 'Test') || ' version' || 
    (if ($wip) then '; marked as WIP)' else ()) ||
    (if (exists($limit-to-steps)) then ('; Limit to ' || $limit-to-steps-sequence) else ())"/>

  <p:identity message="* XProcRef processing ({$type-string})"/>
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
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-before-validation-1.xml"/>
  <xtlc:validate simplify-error-messages="true" p:message="  * Validating primary source">
    <p:with-option name="href-schema" select="$href-xprocref-schema"/>
    <p:with-option name="href-schematron" select="$href-xprocref-schematron"/>
  </xtlc:validate>

  <!-- Handle the step-identity elements: -->
  <p:if test="exists(/*/xpref:steps//xpref:step-identity)">
    <p:xslt message="  * Handling step identities">
      <p:with-input port="stylesheet" href="xsl-process-xprocref/handle-step-identities.xsl"/>
    </p:xslt>
    <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-before-validation-2.xml"/>
    <!-- Just to be sure, re-validate -->
    <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-before-validation-1.xml"/>
    <xtlc:validate simplify-error-messages="true">
      <p:with-option name="href-schema" select="$href-xprocref-schema"/>
      <p:with-option name="href-schematron" select="$href-xprocref-schematron"/>
    </xtlc:validate>
  </p:if>

  <!-- Prepare some attributes and unwrap the step-groups: -->
  <p:unwrap match="xpref:step-group"/>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-xprocref/prepare-xprocref-specification.xsl"/>
  </p:xslt>

  <!-- Remove the unpublished steps when creating a production version: -->
  <p:variable name="step-count-1" as="xs:integer" select="count(/*/xpref:steps/xpref:step)"/>
  <p:if test="exists($limit-to-steps)">
    <p:delete match="xpref:steps/xpref:step[not(xs:string(@name) = {$limit-to-steps-sequence})]"
      message="  * WARNING: Limiting to steps: {$limit-to-steps-sequence}"/>
  </p:if>
  <p:if test="$production-version">
    <p:delete match="xpref:steps/xpref:step[not(xs:boolean((@publish, false())[1]))]"/>
  </p:if>
  <p:variable name="step-count-2" as="xs:integer" select="count(/*/xpref:steps/xpref:step)"/>
  <p:if test="$step-count-2 lt 1">
    <p:error code="xpref:error">
      <p:with-input>
        <p:inline content-type="text/plain">No steps to publish (production-version={$production-version};
          limit-to-steps=({string-join($limit-to-steps, ', ')}))</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-prepared.xml"/>
  <p:identity name="prepared-xprocref-specification" message="  * Step count: {$step-count-2}/{$step-count-1}"/>

  <!-- Clean the result directory: -->
  <xtlc:create-clear-directory clear="true">
    <p:with-option name="href-dir" select="$href-build-location"/>
  </xtlc:create-clear-directory>

  <!-- Copy the web resources: -->
  <local:copy-web-resources p:message="  * Copying web resources">
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
  </local:copy-web-resources>

  <!-- Create a CNAME document (for the GitHub pages): -->
  <p:if test="$production-version and exists($cname)">
    <p:store href="{$href-build-location}/CNAME" serialization="map{'method': 'text'}" message="  * Creating CNAME ({$cname})">
      <p:with-input>
        <p:inline xml:space="preserve" content-type="text/plain">{$cname}</p:inline>
      </p:with-input>
    </p:store>
  </p:if>

  <!-- Create an index document: -->
  <p:xslt>
    <p:with-input pipe="@prepared-xprocref-specification"/>
    <p:with-input port="stylesheet" href="xsl-process-xprocref/create-xprocref-index.xsl"/>
  </p:xslt>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-index.xml"/>
  <p:variable name="xprocref-index" as="document-node()" select="."/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create container: -->

  <!-- Create a container (all text still in DocBook/Markdown): -->
  <p:xslt message="  * Creating pages">
    <p:with-input pipe="@prepared-xprocref-specification"/>
    <p:with-input port="stylesheet" href="xsl-process-xprocref/create-xprocref-container.xsl"/>
    <p:with-option name="parameters" select="map{'xprocref-index': $xprocref-index, 'production-version': $production-version, 'wip': $wip}"/>
  </p:xslt>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-raw-container-X.xml"/>

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-xprocref/fixup-texts.xsl"/>
  </p:xslt>


  <!-- Do the XProc example stuff: -->
  <p:variable name="example-count" as="xs:integer" select="count(//db:xproc-example)"/>
  <p:viewport match="db:xproc-example" name="process-xproc-example" message="  * Handling {$example-count} examples">
    <p:variable name="xproc-example-elm" as="element(db:xproc-example)" select="/*"/>

    <!-- Run the pipeline and add the result, wrapped in <_RESULT>: -->
    <p:variable name="href-pipeline" as="xs:string" select="xs:string(/*/@href)"/>
    <p:run>
      <p:with-input href="{$href-pipeline}"/>
      <p:run-input port="source">
        <!-- Remark: The pipelines we use for the examples are self-sufficient in providing their own input by default. 
          Therefore we supply empty on the source port. -->
        <p:empty/>
      </p:run-input>
      <p:output port="result" primary="true"/>
    </p:run>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-process-xprocref/fixup-example-results.xsl"/>
      <p:with-option name="parameters" select="map{'xproc-example-elm': $xproc-example-elm}"/>
    </p:xslt>
    <p:wrap match="/*" wrapper="_RESULT" name="wrapped-pipeline-result"/>

    <p:insert match="/*" position="last-child">
      <p:with-input port="source" pipe="current@process-xproc-example"/>
      <p:with-input port="insertion" pipe="result@wrapped-pipeline-result"/>
    </p:insert>

    <!-- Use the now enhanced xproc-example element to create the final output for the examples: -->
    <p:xslt name="create-examples">
      <p:with-input port="stylesheet" href="xsl-process-xprocref/create-examples.xsl"/>
      <p:with-option name="parameters" select="map{'xproc-example-elm': $xproc-example-elm}"/>
    </p:xslt>

    <p:store href="file:///C:/xdata/x.xml">
      <p:with-input pipe="@create-examples"/>
    </p:store>

  </p:viewport>

  <!-- Process any Markdown (into DocBook): -->
  <xdoc:markdown-to-docbook p:message="  * Finalizing pages"/>

  <!-- Add a ToC to the steps: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-xprocref/add-toc-to-steps.xsl"/>
  </p:xslt>

  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-raw-container.xml"/>

  <!-- Process the resulting DocBook/xdoc into XHTML: -->
  <p:variable name="html-page-count" as="xs:integer" select="count(/*/xtlcon:document[exists(db:article)])"/>
  <p:viewport match="xtlcon:document[exists(db:article)]" message="  * Converting {$html-page-count} pages to HTML">
    <p:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target)"/>
    <p:viewport match="db:article[1]">
      <xdoc:xdoc-to-xhtml add-numbering="false" add-identifiers="false" create-header="false"/>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-process-xprocref/xhtml-to-page.xsl"/>
        <p:with-option name="parameters"
          select="map{'href-template': $href-web-template, 'href-target': $href-target, 'xprocref-index': $xprocref-index}"/>
      </p:xslt>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-process-xprocref/convert-menu.xsl"/>
      </p:xslt>
    </p:viewport>
  </p:viewport>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/xprocref-final-container.xml"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Finishing: -->

  <!-- Check for any markup errors and report these: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-xprocref/check-for-markup-errors.xsl"/>
  </p:xslt>

  <!-- Write the container to disk: -->
  <xtlcon:container-to-disk remove-target="false" p:message="  * Writing to target">
    <p:with-option name="href-target-path" select="$href-build-location"/>
  </xtlcon:container-to-disk>

  <p:variable name="duration" as="xs:string"
    select="string(current-dateTime() - $start-timestamp) => replace('P', '') => replace('T', ' ') => normalize-space() => lower-case()"/>
  <p:identity message="* XprocRef processing done ({$type-string}; {$step-count-2}/{$step-count-1}) ({$duration})"/>

</p:declare-step>
