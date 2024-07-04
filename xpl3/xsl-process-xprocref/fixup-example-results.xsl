<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ltf_d4h_ybc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       This stylesheet changes the example results. For instance, it will remove any explicit path entries. 
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:include href="../../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="@*[starts-with(., 'file:/')]">
    <xsl:attribute name="{node-name(.)}" select="'file:/…/…/' || xtlc:href-name(.)"/>
  </xsl:template>
  
</xsl:stylesheet>
