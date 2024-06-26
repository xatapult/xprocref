<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.oxf_4nc_wbc"
  xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Performs some fixups on the (DocBook) texts in the container.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="db:port | db:option | db:step | db:property">
    <code role="{local-name(.)}">
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:step-error-ref">
    <xsl:variable name="code" as="xs:string" select="xs:string(@code)"/>
    <code>
      <link xlink:href="#{xpref:error-code-anchor($code)}">{$code}</link>
    </code>
  </xsl:template>

</xsl:stylesheet>
