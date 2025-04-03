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

  <!-- ======================================================================= -->

  <xsl:template match="/*">
    <book version="5.0">
      <xsl:namespace name="db" select="'http://docbook.org/ns/docbook'"/>
      <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
      <xsl:namespace name="xtlcon" select="'http://www.xtpxlib.nl/ns/container'"></xsl:namespace>

      <info>
        <title>XProc {{$XPROCVERSION}} Steps</title>
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

      <xsl:for-each select="/*/xtlcon:document/db:article">
        <xsl:comment> == CHAPTER {db:sect1/db:title} ({@href-target}) == </xsl:comment>
        <chapter>
          <xsl:apply-templates select="@xml:id"/>
          <!-- We're going to remove the sect1 level: -->
          <xsl:apply-templates select="db:sect1/db:*"/>
        </chapter>
      </xsl:for-each>

    </book>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*[matches(local-name(.), '^sect[0-9]$')]">
    <!-- Renumber the sections: -->
    <xsl:variable name="section-number" as="xs:integer" select="xs:integer(substring-after(local-name(.), 'sect'))"/>
    <xsl:element name="db:sect{$section-number - 1}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
