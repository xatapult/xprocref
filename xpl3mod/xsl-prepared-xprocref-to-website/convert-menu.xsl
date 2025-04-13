<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.nxm_shk_xyb" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
    
  xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Adds the menu (replaces element xpref:menu)
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ======================================================================= -->

  <xsl:template match="xpref:menu">
    <div class="container-fluid">
      <ul class="nav justify-content-end nav-pills text-light">
        <xsl:apply-templates select="xpref:menu-entry"/>
      </ul>
    </div>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="xpref:menu/xpref:menu-entry">
    <xsl:choose>
      <xsl:when test="exists(xpref:submenu-entry)">
        <li class="nav-item dropdown lead">
          <a class="nav-link dropdown-toggle text-light" data-bs-toggle="dropdown" href="#">{@caption}</a>
          <ul class="dropdown-menu">
            <xsl:apply-templates select="xpref:submenu-entry"/>
          </ul>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="nav-item lead">
          <a class="nav-link text-light" href="{@href}">{@caption}</a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:menu/xpref:menu-entry/xpref:submenu-entry">
    <li class="lead">
      <a class="dropdown-item" href="{@href}">{@caption}</a>
    </li>
  </xsl:template>

</xsl:stylesheet>
