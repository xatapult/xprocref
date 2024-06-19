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

  <xsl:key name="version-identifiers" match="/*/xpref:versions/xpref:version" use="xs:string(@id)"/>
  <xsl:key name="category-identifiers" match="/*/xpref:categories/xpref:category" use="xs:string(@id)"/>

  <!-- ======================================================================= -->
  <!-- step/@version-idref must exist: -->

  <pattern>
    <rule context="xpref:step/@version-idref">
      <let name="version-idref" value="xs:string(.)"></let>
      <assert test="exists(key('version-identifiers', $version-idref))">A version with identifier "<value-of select="$version-idref"/>" does not exist</assert>
    </rule>
  </pattern>
  
  <!-- ======================================================================= -->
  <!-- step/@category-idrefs must be unique and exist. -->
  
  <pattern>
    <rule context="xpref:step/@category-idrefs">
      <!-- Remark: The schema validation makes the data-type of this attribute a sequence. Since we cannot be sure that schema validation takes place 
        beforehand, tie it together again first... :( -->
      <let name="category-idrefs" value="tokenize(string-join(., ' '), '\s')[.]"/>
      <assert test="every $ref in $category-idrefs satisfies exists(key('category-identifiers', $ref))">The value of @<value-of
        select="local-name(.)"/> "<value-of select="$category-idrefs"/>" references non-existing categories.</assert>
      <assert test="count($category-idrefs) eq count(distinct-values($category-idrefs))">The value of @<value-of
        select="local-name(.)"/> "<value-of select="$category-idrefs"/>" contains duplicate values.</assert>
    </rule>
  </pattern>
  
</schema>
