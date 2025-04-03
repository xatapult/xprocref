<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" xmlns:local="#local.k5v_f3j_w2c"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Limits an XprocRef spec to the latest version.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES: -->
  
  <xsl:variable name="latest-version-id" as="xs:string" select="x"/>
  
  <!-- ======================================================================= -->
  
  
  <xsl:template match="xpref:steps/xpref:step[@version-idref ne $latest-version-id]"> 
    
  </xsl:template>

</xsl:stylesheet>
