<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.r3f_3x1_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  version="3.0" exclude-inline-prefixes="#all" name="convert-steps" type="xpref:convert-steps">

  <p:documentation>
    Takes a container structure with the steps in "specification source format" and turns these into raw XprocRef format.
    
    IMPORTANT: This is intended as a one-time action. After this, the result must be hand-edited.
    
    Container specification:
    * Must be a valid xtpxlib 3.0 container
    * Must have /*/@href-target-path
    * Must have /*/name (Short human readable name of the steps)
    * Must have /*/@specification-baselink (so we can generate a test XProcRef document)
    * All steps must wrapped in a xtlcon:document element
      * Must have @type="step"
    
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>
  <p:import href="../../xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The container structure with steps in specification format.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A report thingy.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-xprocref-schema" as="xs:string" required="false" select="resolve-uri('../xsd/xprocref.xsd', static-base-uri())"/>

  <p:option name="version-idref" as="xs:string" required="false" select="'v30'"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:variable name="name" as="xs:string" select="xs:string(/*/@name)"/>
  <p:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target-path)"/>

  <!-- Do the conversion things: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl/convert-steps-1.xsl"/>
    <p:with-option name="parameters" select="map{'version-idref': $version-idref, 'href-xprocref-schema': $href-xprocref-schema }"/>
  </p:xslt>

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl/fixup-signature.xsl"/>
  </p:xslt>
  
  <p:unwrap match="xpref:rfc2119"/>
  <p:unwrap match="xpref:glossterm"/>
  <p:unwrap match="xpref:impl"/>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl/fixup-texts-and-errors.xsl"/>
  </p:xslt>

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl/finalize-steps-container.xsl"/>
  </p:xslt>

  <!-- Add the additional documents: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl/add-additional-documents.xsl"/>
  </p:xslt>

  <!-- Write the result: -->
  <xtlcon:container-to-disk p:message="* Writing result to {$href-target}"/>

  <!-- Go over them again to remove the xtlcon namespace: -->
  <xtlc:recursive-directory-list depth="1" flatten="true" p:message="* Removing superfluous namespaces">
    <p:with-option name="path" select="$href-target"/>
  </xtlc:recursive-directory-list>

  <p:for-each>
    <p:with-input select="/c:directory/c:file"/>
    <p:variable name="href-abs" as="xs:string" select="xs:string(/*/@href-abs)"/>
    <p:xslt>
      <p:with-input href="{$href-abs}"/>
      <p:with-input port="stylesheet" href="xsl/remove-superfluous-namespaces.xsl"/>
    </p:xslt>
    <p:store href="{$href-abs}" serialization="map{'indent': true()}"/>
  </p:for-each>
  <p:variable name="count" as="xs:integer" select="count(collection())" collection="true"/>

  <!-- Create a report thingy: -->
  <p:identity>
    <p:with-input>
      <convert-steps name="{$name}" count="{$count}" timestamp="{current-dateTime()}" href-target="{$href-target}"/>
    </p:with-input>
  </p:identity>

</p:declare-step>
