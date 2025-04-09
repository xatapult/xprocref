<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lzl_q53_y2c"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Postprocess the DocBook created for widows/orphans and other stuff.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:link[exists(@xlink:href)][not(starts-with(normalize-space(.), 'http'))]">
    <!-- Make sure all external referenced links are visible in print. -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="@xlink:href"/>
      <xsl:text>)</xsl:text>
    </xsl:copy>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- TABLE COLUMN WIDTHS: -->

  <xsl:template match="db:table[contains-token(@role, $xpref:role-error-codes-table)]/db:tgroup">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <db:colspec colwidth="20%"/>
      <xsl:apply-templates select="db:*"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:table[contains-token(@role, $xpref:role-ports-table)]/db:tgroup">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <db:colspec colwidth="{local:compute-code-column-width(., 1, 10)}%"/>
      <db:colspec colwidth="9%"/>
      <db:colspec colwidth="10%"/>
      <db:colspec colwidth="{local:compute-code-column-width(., 4, 10, 25)}%"/>
      <db:colspec colwidth="9%"/>
      <xsl:apply-templates select="db:*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="db:table[contains-token(@role, $xpref:role-options-table)]/db:tgroup">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="cols" as="xs:integer" select="xs:integer(@cols)"/>
      <db:colspec colwidth="{local:compute-code-column-width(., 1, 10)}%"/>
      <db:colspec colwidth="20%"/>
      <db:colspec colwidth="9%"/>
      <xsl:if test="$cols gt 4">
        <db:colspec colwidth="{local:compute-code-column-width(., 4, 9, 20)}%"/>
      </xsl:if>
      <xsl:apply-templates select="db:*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ======================================================================= -->
  
  <xsl:function name="local:compute-code-column-width" as="xs:integer">
    <!-- Computes the width (in approximate percents) of a column containing code entries. Minimum is always 10.-->
    <xsl:param name="tgroup" as="element(db:tgroup)"/>
    <xsl:param name="colnr" as="xs:integer"/>
    <xsl:param name="minwidth" as="xs:integer"/>
    <xsl:param name="maxwidth" as="xs:integer">
      <!-- If le 0, there is no maxwidth -->
    </xsl:param>
    
    <!-- Get all the column contents (the words) and find the length of the longest: -->
    <xsl:variable name="contents" as="xs:string*" select="for $e in $tgroup/db:tbody/db:row/db:entry[$colnr]/string() return tokenize($e, '\s+')[.]"/>
    <xsl:variable name="max-length" as="xs:integer" select="max(for $c in $contents return string-length($c))"/>
    
    <!-- Compute some width: -->
    <xsl:variable name="width" as="xs:integer" select="(xs:double($max-length) * 1.35) => ceiling() => xs:integer()"/>
    <xsl:choose>
      <xsl:when test="$width le $minwidth">
        <xsl:sequence select="$minwidth"/>
      </xsl:when>
      <xsl:when test="($maxwidth gt 0) and ($width gt $maxwidth)">
        <xsl:sequence select="$maxwidth"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$width"/>
      </xsl:otherwise>  
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:compute-code-column-width" as="xs:integer">
    <!-- Computes the width (in approximate percents) of a column containing code entries. Minimum is always 10.-->
    <xsl:param name="tgroup" as="element(db:tgroup)"/>
    <xsl:param name="colnr" as="xs:integer"/>
    <xsl:param name="minwidth" as="xs:integer"/>
    
    <xsl:sequence select="local:compute-code-column-width($tgroup, $colnr, $minwidth, -1)"/>
  </xsl:function>
  


</xsl:stylesheet>
