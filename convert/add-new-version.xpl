<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.k4x_ckf_njc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" name="add-new-version">

  <p:documentation>
    This pipeline takes an existing XProc version directory and bootstraps this into a new one. For all steps, appropriate step-identity
    documents are created. step-groups are updated.
    
    It also tries to update the macros with a version prefix. This may not be perfect, please check.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import-functions href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report about what's done.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-source-base-dir" as="xs:string" required="false" select="resolve-uri('../src/', static-base-uri())">
    <p:documentation>The base directory that contains the sources for the various versions of the step. 
      It must have sub-directories with the same names as the versions!</p:documentation>
  </p:option>

  <p:option name="href-target-base-dir" as="xs:string" required="false" select="resolve-uri('../build/', static-base-uri())">
    <p:documentation>The base directory for writing the new version stuff to. A sub-directory with the name of this version is created.
      Usually not the final target (which would be the same as $href-source-base-dir), so you don't accidentally overwrite stuff.
    </p:documentation>
  </p:option>

  <p:option name="source-version" as="xs:string" required="false" select="'3.1'">
    <p:documentation>The version to use as a source for creating the new version (usually the previous one).</p:documentation>
  </p:option>

  <p:option name="target-version" as="xs:string" required="false" select="'3.2'">
    <p:documentation>The version to create.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:identity message="* Creating version {$target-version} from {$source-version}">
    <p:with-input>
      <p:empty></p:empty>
    </p:with-input>
  </p:identity>

  <!-- Setup: -->
  <p:variable name="href-source-dir" as="xs:string" select="xtlc:href-concat(($href-source-base-dir, $source-version))"/>
  <p:variable name="href-target-dir" as="xs:string" select="xtlc:href-concat(($href-target-base-dir, $target-version))"/>
  
  <xtlc:create-clear-directory clear="true" p:message="* Clearing target dir {$href-target-dir}">
    <p:with-option name="href-dir" select="$href-target-dir" />
  </xtlc:create-clear-directory>
  
  <!-- Get the contents of the source directory: -->
  <xtlc:recursive-directory-list flatten="true" include-filter="\.xml$" p:message="* Source directory {$href-source-dir}">
    <p:with-option name="path" select="$href-source-dir"/>
  </xtlc:recursive-directory-list>
  
</p:declare-step>
