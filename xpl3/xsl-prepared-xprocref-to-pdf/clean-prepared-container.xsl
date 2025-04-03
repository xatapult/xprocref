<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.nyw_5fq_w2c"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Removes all kinds of markup from the prepared XProcRef container that 
       we don't need in the PDF.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="db:article/db:info">
    <!-- We will only use the contents of the articles. -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:para[$xpref:role-page-banner = xtlc:str2seq(@role)]">
    <!-- Remove warning messages, etc. -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:sect1/db:title">
    <!-- Remove the next/prev markers and remove anything between brackets (usually a version remark/marker): -->
    
    <xsl:variable name="title-text" as="xs:string" select="(text()[normalize-space(.) ne ''])[1]"/>
    <xsl:comment> == Original title: "{$title-text}" == </xsl:comment>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace($title-text, '\(.+\)', '') => translate('&#160;', ' ') => normalize-space()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="db:sect1/db:itemizedlist[$xpref:role-toc = xtlc:str2seq(@role)]">
    <!-- Remove the page ToC entries. -->
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="db:sect2[$xpref:role-reference-section = xtlc:str2seq(@role)]">
    <!-- We don't need this in a PDF. -->
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="db:sect2[$xpref:role-site-remark = xtlc:str2seq(@role)]">
    <!-- We don't need this in a PDF. -->
  </xsl:template>
  
</xsl:stylesheet>
