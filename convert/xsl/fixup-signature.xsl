<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.e3g_vqb_wbc"  xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax"
  xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Makes the step signatures valid
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="edit-marker" as="xs:string" select="xs:string(/*/@edit-marker)"/>

  <!-- ================================================================== -->

  <xsl:template match="xpref:signature/(xpref:input | xpref:output)">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="empty(@primary)">
        <xsl:attribute name="primary" select="true()"/>
      </xsl:if>
      <xsl:if test="empty(@sequence)">
        <xsl:attribute name="sequence" select="true()"/>
      </xsl:if>
      <xsl:if test="empty(@content-types)">
        <!-- Is this ok? -->
        <xsl:attribute name="content-types" select="'xml'"/>
      </xsl:if>
      <xsl:if test="exists(self::xpref:input) and exists(xpref:empty)">
        <xsl:attribute name="empty" select="true()"/>
      </xsl:if>
      <xsl:call-template name="add-description"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ======================================================================= -->
  
  <xsl:template match="xpref:signature/xpref:option">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="empty(@required)">
        <xsl:attribute name="required" select="false()"/>
      </xsl:if>
      <xsl:if test="empty(@as)">
        <xsl:attribute name="as" select="'item()*'"/>
      </xsl:if>
      <xsl:call-template name="add-description"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="@e:type">
    <xsl:attribute name="subtype" select="."/>
  </xsl:template>
  
  <!-- ======================================================================= -->

  <xsl:template name="add-description">
    <xsl:param name="elm" as="element()" required="false" select="."/>

    <xsl:variable name="name" as="xs:string" select="($elm/@port, $elm/@name, '?')[1]"/>
    <description>
      <para>{$edit-marker} {local-name($elm)} {$name}</para>
    </description>
  </xsl:template>

</xsl:stylesheet>
