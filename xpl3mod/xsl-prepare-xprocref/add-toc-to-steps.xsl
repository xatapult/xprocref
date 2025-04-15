<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.bkd_wck_wbc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Adds a ToC to the steps
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:template match="xtlcon:document[@type eq $xpref:type-step]/db:article/db:sect1">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <!-- Copy the title and the short description first: -->
      <xsl:apply-templates select="db:*[position() le 2]"/>

      <xsl:call-template name="add-toc-list-for-level">
        <xsl:with-param name="level" select="2"/>
      </xsl:call-template>

      <xsl:apply-templates select="db:*[position() gt 2]"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-toc-list-for-level">
    <xsl:param name="root" as="element()" required="false" select="."/>
    <xsl:param name="level" as="xs:integer" required="true"/>

    <xsl:variable name="subsect-element-name" as="xs:string" select="'sect' || $level"/>
    <xsl:variable name="subsects" as="element()*" select="$root/db:*[local-name(.) eq $subsect-element-name]"/>
    <xsl:if test="exists($subsects)">
      <itemizedlist role="{$xpref:role-toc} {$xpref:role-toc}-{$level}">
        <xsl:for-each select="$subsects">
          <listitem role="{$xpref:role-toc} {$xpref:role-toc}-{$level}">
            <para role="{$xpref:role-tocentry} {$xpref:role-tocentry}-{$level}">
              <link xlink:href="#{@xml:id}">{normalize-space(db:title)}</link>
            </para>
            <xsl:if test="$level lt $xpref:max-section-level">
              <xsl:call-template name="add-toc-list-for-level">
                <xsl:with-param name="level" select="$level + 1"/>
              </xsl:call-template>
            </xsl:if>
          </listitem>
        </xsl:for-each>
      </itemizedlist>
    </xsl:if>

  </xsl:template>


</xsl:stylesheet>
