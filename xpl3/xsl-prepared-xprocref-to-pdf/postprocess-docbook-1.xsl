<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lzl_q53_y2c"
  xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Postprocess the DocBook created for widows/orphans and other stuff.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="db:para[exists(following-sibling::db:*[1]/self::db:programlisting)]">
    <!-- Paragraphs followed by a program listing must be kept together with this. -->
    <xsl:copy>
      <xsl:attribute name="role" select="(@role || ' ' || 'keep-with-next') => normalize-space()"/>
      <xsl:apply-templates select="(@* except @role) | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="db:link[exists(@linkend)]">
    <!-- Have all internal links followed by a page number. -->
    <xsl:copy-of select="."/>
    <xsl:text> (pg.&#160;</xsl:text>
    <xref role="page-number-only">
      <xsl:copy-of select="@linkend"/>
    </xref>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  
</xsl:stylesheet>
