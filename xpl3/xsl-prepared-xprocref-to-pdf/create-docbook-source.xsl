<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.nyw_5fq_w2c"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true"
  xmlns="http://docbook.org/ns/docbook">
  <!-- ================================================================== -->
  <!-- 
       Turns everything into a DocBook book, with chapters.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:param name="href-dir-images" as="xs:string" required="true"/>

  <xsl:param name="href-introduction-chapter" as="xs:string" required="false"
    select="resolve-uri('../../data/pdf-introduction-chapter.xml', static-base-uri())"/>

  <!-- ======================================================================= -->

  <xsl:template match="/*">
    <book version="5.0">
      <xsl:namespace name="db" select="'http://docbook.org/ns/docbook'"/>
      <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
      <xsl:namespace name="xtlcon" select="'http://www.xtpxlib.nl/ns/container'"/>

      <!-- General info: -->
      <info>
        <title>XProc {{$XPROCVERSION}} Step Reference</title>
        <!--<subtitle>A description of all steps in XProc {{$XPROCVERSION}}</subtitle>-->
        <pubdate>{{$DATE}}</pubdate>
        <author>
          <personname>Erik Siegel</personname>
        </author>
        <orgname>Xatapult</orgname>
        <mediaobject role="top-logo">
          <imageobject>
            <imagedata fileref="{xtlc:href-concat(($href-dir-images, 'logo-xatapult.jpg'))}" role="altwidth:10%" width="10%"/>
          </imageobject>
        </mediaobject>
        <mediaobject role="center-page">
          <imageobject>
            <imagedata fileref="{xtlc:href-concat(($href-dir-images, 'xproc-logo.jpg'))}" role="altwidth:20%" width="20%"/>
          </imageobject>
        </mediaobject>
      </info>

      <!-- Introduction: -->
      <xsl:copy-of select="doc($href-introduction-chapter)"/>

      <!-- Chapters: -->
      <xsl:call-template name="add-steps-chapter"/>
      <xsl:call-template name="add-categories-chapter"/>
      <xsl:call-template name="add-appendices"/>
      
    </book>

  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template name="add-steps-chapter">
    <chapter xml:id="steps">
      <title>Steps</title>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Overview page for the steps: -->

      <sect1>
        <title>Overview</title>

        <xsl:variable name="index-article" as="element(db:article)" select="/*/xtlcon:document[@type eq $xpref:type-all-steps-for-version]/db:article"/>
        <xsl:copy-of select="$index-article/db:sect1[1]/db:para[normalize-space(.) ne '']"/>
        <xsl:call-template name="process-alphabetical-link-list">
          <xsl:with-param name="sect1" select="$index-article/db:sect1[1]"/>
        </xsl:call-template>
      </sect1>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- All steps: -->

      <xsl:for-each select="/*/xtlcon:document[@type eq $xpref:type-step]">
        <xsl:variable name="id" as="xs:string" select="xs:string(@xml:id)"/>
        <xsl:for-each select="db:article/db:sect1">
          <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="$id"/>
            <xsl:copy-of select="db:*"/>
          </xsl:copy>
        </xsl:for-each>

      </xsl:for-each>

    </chapter>


  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-categories-chapter">
    <chapter xml:id="categories">
      <title>Categories</title>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Overview section with all categories: -->

      <xsl:variable name="categories-article" as="element(db:article)"
        select="/*/xtlcon:document[@type eq $xpref:type-categories-overview]/db:article"/>
      <xsl:variable name="id" as="xs:string" select="xs:string($categories-article/@xml:id)"/>
      <xsl:for-each select="$categories-article/db:sect1[1]">
        <xsl:copy>
          <xsl:attribute name="xml:id" select="$id"/>
          <xsl:copy-of select="@* except @xml:id"/>
          <title>Overview</title>
          <xsl:copy-of select="db:* except db:title"/>
        </xsl:copy>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Section per category: -->

      <xsl:variable name="category-articles" as="element(db:article)*" select="/*/xtlcon:document[@type eq $xpref:type-category]/db:article"/>

      <xsl:for-each select="$category-articles/db:sect1[1]">
        <xsl:variable name="id" as="xs:string" select="xs:string(../@xml:id)"/>
        <xsl:copy>
          <xsl:attribute name="xml:id" select="$id"/>
          <xsl:copy-of select="@* except @xml:id"/>
          <title>{replace(xs:string(db:title), '^Category:\s+', '')}</title>
          <xsl:copy-of select="db:para[normalize-space(.) ne '']"/>
          <xsl:call-template name="process-alphabetical-link-list"/>
        </xsl:copy>
      </xsl:for-each>

    </chapter>

  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="add-appendices">
    <!-- Add the appendices about errors, namespaces, etc. -->
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Error codes: -->
    
    <xsl:variable name="error-codes-article" as="element(db:article)" select="/*/xtlcon:document[@type eq $xpref:type-error-codes]/db:article"/>
    <appendix xml:id="{$error-codes-article/@xml:id}">
      <xsl:copy-of select="$error-codes-article/db:sect1[1]/db:*"/>
    </appendix>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Namespaces: -->
    
    <xsl:variable name="namespaces-article" as="element(db:article)" select="/*/xtlcon:document[@type eq $xpref:type-namespaces]/db:article"/>
    <appendix xml:id="{$namespaces-article/@xml:id}">
      <xsl:copy-of select="$namespaces-article/db:sect1[1]/db:*"/>
    </appendix>
    
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="process-alphabetical-link-list">
    <!-- Processes an alphabetical link list into DocBook suitable for the PDF. -->
    <xsl:param name="sect1" as="element(db:sect1)" required="false" select=".">
      <!-- The surrounding <sect1> element. The <sect2> elements are supposed to hold the alphabetical sub-sections. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="exists($sect1/db:sect2)">
        <xsl:for-each select="$sect1/db:sect2">
          <bridgehead>{db:title}</bridgehead>
          <xsl:copy-of select="db:* except db:title"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- No alphabetical sections, this is is just a simple itemized list: -->
        <xsl:copy-of select="$sect1/db:itemizedlist[1]"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
</xsl:stylesheet>
