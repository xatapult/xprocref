<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">
  <!-- ================================================================== -->
  <!--
    Schematron schema for xprocref.   
  -->
  <!-- ================================================================== -->

  <ns uri="http://www.xtpxlib.nl/ns/xprocref" prefix="xpref"/>

  <!-- ======================================================================= -->
  <!-- Define the keys for the identifier lookups: -->

  <let name="defined-version-ids" value="/*/xpref:versions/xpref:version/@id/string()"/>
  <let name="defined-category-ids" value="/*/xpref:categories/xpref:category/@id/string()"/>
  <let name="defined-namespace-prefixes" value="/*/xpref:namespaces/xpref:namespace/@prefix/string()"/>
  <let name="defined-error-codes" value="/*/xpref:errors/xpref:error/@code/string()"/>

  <!-- ======================================================================= -->
  <!-- Check the version id referencest: -->

  <pattern>
    <rule context="(xpref:step | xpref:step-identity)/@version-idref">
      <let name="version-idref" value="string(.)"/>
      <assert test="$version-idref = $defined-version-ids">A version with identifier "<value-of select="$version-idref"/>" does not exist</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="xpref:step-identity/@base-version-idref">
      <let name="version-idref" value="string(.)"/>
      <assert test="$version-idref = $defined-version-ids">A base version with identifier "<value-of select="$version-idref"/>" does not exist</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Check the category id references: -->

  <pattern>
    <rule context="(xpref:step | xpref:step-identity)/@category-idrefs">
      <let name="category-idrefs" value="tokenize(., '\s')[.]"/>
      <assert test="every $ref in $category-idrefs satisfies ($ref = $defined-category-ids)">The value of @<value-of select="local-name(.)"/>
          "<value-of select="$category-idrefs"/>" references non-existing categories.</assert>
      <assert test="count($category-idrefs) eq count(distinct-values($category-idrefs))">The value of @<value-of select="local-name(.)"/> "<value-of
          select="$category-idrefs"/>" contains duplicate values.</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Checks on namespace prefixes: -->

  <pattern>
    <rule context="xpref:step | xpref:step-identity">
      <let name="namespace-prefix" value="xs:string((@namespace-prefix, 'p')[1])"/>
      <assert test="$namespace-prefix = $defined-namespace-prefixes">The step namespace prefix "<value-of select="$namespace-prefix"/>" is
        undefined.</assert>
    </rule>
  </pattern>

  <pattern>
    <rule context="xpref:namespaces">
      <let name="error-namespace-definitions" value="xpref:namespace[xs:boolean((@error-namespace, false())[1])]"/>
      <assert test="count($error-namespace-definitions) eq 1">There must be exactly one error namespace.</assert>
    </rule>

  </pattern>

  <!-- ======================================================================= -->
  <!-- Check error codes in steps: -->

  <pattern>
    <rule context="xpref:step-error-ref">
      <let name="error-code" value="xs:string(@code)"/>
      <let name="defined-step-error-codes" value="ancestor::xpref:step/xpref:step-errors/xpref:step-error/@code/string()"/>
      <assert test="exists(ancestor::xpref:step) or exists(ancestor::xpref:step-identity) ">A <value-of select="local-name(.)"/> element can only be used within a step.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="xpref:step-error-ref[exists(ancestor::xpref:step)]">
      <let name="error-code" value="xs:string(@code)"/>
      <let name="defined-step-error-codes" value="ancestor::xpref:step/xpref:step-errors/xpref:step-error/@code/string()"/>
      <assert test="$error-code = $defined-step-error-codes">The error code "<value-of select="$error-code"/>" is not defined for this step.</assert>
    </rule>
  </pattern>

  <pattern>
    <rule context="xpref:step-error">
      <let name="error-code" value="xs:string(@code)"/>
      <assert test="$error-code = $defined-error-codes">The error code "<value-of select="$error-code"/>" is undefined.</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Check the step signatures: -->

  <pattern>
    <rule context="xpref:step/xpref:signature">
      <assert test="count(xpref:input[xs:boolean(@primary)]) le 1">Step signature has more than one primary input port.</assert>
      <assert test="count(xpref:output[xs:boolean(@primary)]) le 1">Step signature has more than one primary output port.</assert>
    </rule>
  </pattern>

  <pattern>
    <rule context="xpref:step/xpref:signature/xpref:option[xs:boolean(@required)]">
      <assert test="empty(@select)">A required option cannot have a select attribute.</assert>
    </rule>
  </pattern>

</schema>
