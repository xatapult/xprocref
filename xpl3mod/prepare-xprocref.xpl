<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" name="prepare-xprocref" type="xpref:prepare-xprocref">

  <p:documentation>
    Pipeline that prepares the XProcRef sources into an xtpxlib container with (mainly) DocBook sources for the pages.
    Because of historical reasons, this container is primarily intended for converting stuff to the XProcRef HTML pages.
    However, there is additional data added so we can more easily create other output formats as well.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/validate/validate.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/expand-macro-definitions/expand-macro-definitions.xpl"/>

  <p:import href="../../xtpxlib-xdoc/xpl3mod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The main XProcRef specification to process</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting xtpxlib container.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- DEBUG SETTINGS -->

  <p:option name="write-intermediate-results" as="xs:boolean" required="false" select="true()"/>
  <p:option name="href-intermediate-results" as="xs:string" required="false" select="resolve-uri('../tmp', static-base-uri())"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

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

  <p:option name="limit-to-latest-version" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to limit the output to the latest version only.</p:documentation>
  </p:option>
  
  <p:option name="prompt" as="xs:string" required="false" select="'Preparations:'">
    <p:documentation>The main/first prompt in the message output</p:documentation>
  </p:option>
  
  <!-- ======================================================================= -->
  <!-- GLOBAL SETTINGS: -->

  <p:variable name="href-xprocref-schema" as="xs:string" select="resolve-uri('../xsd/xprocref.xsd', static-base-uri())"/>
  <p:variable name="href-xprocref-schematron" as="xs:string" select="resolve-uri('../sch/xprocref.sch', static-base-uri())"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Preparations: -->

  <p:identity message="  * {$prompt}"/>
  <p:variable name="limit-to-steps-sequence" as="xs:string"
    select="'(' || string-join(for $s in $limit-to-steps return ('''' || $s || ''''), ', ') || ')'"/>

  <!-- Process any XIncludes and record the original base URIs: -->
  <p:xinclude/>
  <p:add-xml-base relative="false"/>

  <!-- Delete schema references (annoying, since they are no longer valid): -->
  <p:delete match="@xsi:*"/>
  <p:namespace-delete prefixes="xsi"/>
  <p:delete match="processing-instruction(xml-model)"/>

  <!-- Validate: -->
  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/010-xprocref-after-xinclude.xml"/>
  </p:if>
  <xtlc:validate simplify-error-messages="true" p:message="    * Validating primary source">
    <p:with-option name="href-schema" select="$href-xprocref-schema"/>
    <p:with-option name="href-schematron" select="$href-xprocref-schematron"/>
  </xtlc:validate>

  <!-- Handle the step-identity elements: -->
  <p:if test="exists(/*/xpref:steps//xpref:step-identity)">
    <p:xslt message="    * Handling step identities">
      <p:with-input port="stylesheet" href="xsl-prepare-xprocref/handle-step-identities.xsl"/>
    </p:xslt>
    <p:if test="$write-intermediate-results">
      <p:store href="{$href-intermediate-results}/020-xprocref-after-step-identities.xml"/>
    </p:if>
  </p:if>

  <!-- Expand any macros: -->
  <xtlc:expand-macro-definitions/>
  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/030-xprocref-after-expand-macro-definitions.xml"/>
  </p:if>

  <!-- Just to be sure, re-validate -->
  <xtlc:validate simplify-error-messages="true">
    <p:with-option name="href-schema" select="$href-xprocref-schema"/>
    <p:with-option name="href-schematron" select="$href-xprocref-schematron"/>
  </xtlc:validate>

  <!-- Prepare some attributes and unwrap the step-groups: -->
  <p:unwrap match="xpref:step-group"/>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepare-xprocref/prepare-xprocref-specification.xsl"/>
  </p:xslt>

  <!-- Limit things to the latest version if requested: -->
  <p:if test="$limit-to-latest-version">
    <p:variable name="latest-version-id" as="xs:string" select="xs:string(/*/xpref:versions/xpref:version[1]/@id)"/>
    <p:variable name="latest-version-name" as="xs:string" select="xs:string(/*/xpref:versions/xpref:version[1]/@name)"/>
    <p:identity message="    * Limiting to latest version {$latest-version-name}"/>
    <p:delete match="xpref:versions/xpref:version[@id ne '{$latest-version-id}']"/>
    <p:delete match="xpref:steps/xpref:step[@version-idref ne '{$latest-version-id}']"/>
  </p:if>

  <!-- Remove the unpublished steps when creating a production version: -->
  <p:variable name="step-count-1" as="xs:integer" select="count(/*/xpref:steps/xpref:step)"/>
  <p:if test="exists($limit-to-steps)">
    <p:delete match="xpref:steps/xpref:step[not(xs:string(@name) = {$limit-to-steps-sequence})]"
      message="    * Limiting to steps: {$limit-to-steps-sequence}"/>
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
  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/040-xprocref-prepared.xml"/>
  </p:if>
  <p:identity name="prepared-xprocref-specification" message="    * Step count: {$step-count-2}/{$step-count-1}"/>

  <!-- Create an index document: -->
  <p:xslt>
    <p:with-input pipe="@prepared-xprocref-specification"/>
    <p:with-input port="stylesheet" href="xsl-prepare-xprocref/create-xprocref-index.xsl"/>
  </p:xslt>
  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/050-xprocref-index.xml"/>
  </p:if>
  <p:variable name="xprocref-index" as="document-node()" select="."/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create container: -->

  <!-- Create a container (all text still in DocBook/Markdown): -->
  <p:xslt message="    * Creating pages">
    <p:with-input pipe="@prepared-xprocref-specification"/>
    <p:with-input port="stylesheet" href="xsl-prepare-xprocref/create-xprocref-container.xsl"/>
    <p:with-option name="parameters" select="map{'xprocref-index': $xprocref-index, 'production-version': $production-version, 'wip': $wip}"/>
  </p:xslt>

  <!-- Handle all kinds of XProcRef specific markup into DocBook: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepare-xprocref/fixup-texts.xsl"/>
  </p:xslt>

  <!-- Do the XProc example stuff: -->
  <p:variable name="example-count" as="xs:integer" select="count(//db:xproc-example)"/>
  <p:viewport match="db:xproc-example" name="process-xproc-example" message="    * Handling {$example-count} examples">
    <p:if test="(p:iteration-position() mod 10) eq 0">
      <p:identity message="      * Example {p:iteration-position()}/{$example-count}"/>
    </p:if>

    <p:variable name="xproc-example-elm" as="element(db:xproc-example)" select="/*"/>
    <p:variable name="output-is-text" as="xs:boolean" select="xs:boolean((/*/@output-is-text, false())[1])"/>

    <!-- Get the pipeline href and use this to remove any existing build/ and tmp/ directories for the example:: -->
    <p:variable name="href-pipeline" as="xs:string" select="xs:string(/*/@href)"/>
    <p:variable name="href-pipeline-dir" as="xs:string" select="replace($href-pipeline, '(.*)[/\\][^/\\]+$', '$1')"/>
    <p:file-delete fail-on-error="false" recursive="true">
      <p:with-option name="href" select="string-join(($href-pipeline-dir, 'build/'), '/')"/>
    </p:file-delete>
    <p:file-delete fail-on-error="false" recursive="true">
      <p:with-option name="href" select="string-join(($href-pipeline-dir, 'tmp/'), '/')"/>
    </p:file-delete>

    <!-- Run the pipeline and add the result, wrapped in <_RESULT>: -->
    <p:load href="{$href-pipeline}" name="example-pipeline"/>
    <p:variable name="has-source-port" as="xs:boolean" select="exists(/*/p:input[@port eq'source'])"/>
    <p:choose>
      <p:when test="$has-source-port">
        <p:run>
          <p:with-input pipe="@example-pipeline"/>
          <p:run-input port="source">
            <!-- Remark: The pipelines we use for the examples are self-sufficient in providing their own input by default. 
             Therefore we supply empty on the source port. -->
            <p:empty/>
          </p:run-input>
          <p:output port="result" primary="true" sequence="true"/>
        </p:run>
      </p:when>
      <p:otherwise>
        <p:run>
          <p:with-input pipe="@example-pipeline"/>
          <p:output port="result" primary="true" sequence="true"/>
        </p:run>
      </p:otherwise>
    </p:choose>
    <p:if test="$output-is-text">
      <p:cast-content-type content-type="text/plain"/>
    </p:if>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-prepare-xprocref/fixup-example-results.xsl"/>
      <p:with-option name="parameters" select="map{'xproc-example-elm': $xproc-example-elm}"/>
    </p:xslt>
    <p:wrap match="/*" wrapper="_RESULT" name="wrapped-pipeline-result"/>

    <p:insert match="/*" position="last-child">
      <p:with-input port="source" pipe="current@process-xproc-example"/>
      <p:with-input port="insertion" pipe="result@wrapped-pipeline-result"/>
    </p:insert>

    <!-- Use the now enhanced xproc-example element to create the final output for the examples: -->
    <p:xslt name="create-examples">
      <p:with-input port="stylesheet" href="xsl-prepare-xprocref/create-examples.xsl"/>
      <p:with-option name="parameters" select="map{'xproc-example-elm': $xproc-example-elm, 'has-source-port': $has-source-port}"/>
    </p:xslt>

  </p:viewport>

  <!-- Process any Markdown (into DocBook): -->
  <xdoc:markdown-to-docbook p:message="    * Finalizing pages"/>

  <!-- Add a ToC to the steps: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-prepare-xprocref/add-toc-to-steps.xsl"/>
  </p:xslt>

  <!-- Add some additional information to the container root: -->
  <p:set-attributes match="/*">
    <p:with-option name="attributes" select="map{
      'production-version': $production-version,
      'limit-to-steps': string-join($limit-to-steps, ' '),
      'wip': $wip,
      'limit-to-latest-version': $limit-to-latest-version,
      'all-steps-count': $step-count-1,
      'processed-steps-count': $step-count-2
    }"/>
  </p:set-attributes>

  <p:if test="$write-intermediate-results">
    <p:store href="{$href-intermediate-results}/060-xprocref-raw-container-docbook.xml"/>
  </p:if>

</p:declare-step>
