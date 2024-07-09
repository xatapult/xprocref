<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.fqd_cvr_zbc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref" exclude-result-prefixes="#all" expand-text="true"
  xmlns="http://www.xtpxlib.nl/ns/xprocref">
  <!-- ================================================================== -->
  <!-- 
       Turns the <step-identity> elements into full <step> elements
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="xpref:step-identity">

    <xsl:variable name="step-identity" as="element(xpref:step-identity)" select="."/>
    <xsl:variable name="step-name" as="xs:string" select="xs:string($step-identity/@name)"/>
    <xsl:variable name="base-version-id" as="xs:string" select="xs:string($step-identity/@base-version-idref)"/>
    <xsl:variable name="namespace-prefix" as="xs:string" select="xs:string(($step-identity/@namespace-prefix, $xpref:default-namespace-prefix)[1])"/>

    <!-- Find the base step specification -->
    <xsl:variable name="base-step" as="element(xpref:step)?" select="/*/xpref:steps//xpref:step
        [@version-idref eq $base-version-id]
        [@name eq $step-name]
        [xs:string((@namespace-prefix, $xpref:default-namespace-prefix)[1]) eq $namespace-prefix]"/>
    <xsl:if test="empty($base-step)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts"
          select="('Could not find a base step ', $namespace-prefix, ':', $step-name, ' for version id ', $base-version-id)"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Create the step: -->
    <step>
      <!-- We copy the relevant attributes from the <step-identity> and amend these with attributes from the base <step> that are not on the <step-identity>: -->
      <xsl:variable name="identity-attribute-names" as="xs:string+" select="for $att in $step-identity/@* return local-name($att)"/>
      <xsl:copy-of select="$step-identity/@* except $step-identity/@base-version-idref"/>
      <xsl:copy-of select="$base-step/@* except $base-step/@*[local-name(.) = $identity-attribute-names]"/>

      <!-- Remark: The xpref:macrodefs is already expanded and therefore does not need to be copied. -->

      <xsl:call-template name="copy-element-if-not-exists">
        <xsl:with-param name="step-identity-elm" select="$step-identity/xpref:signature"/>
        <xsl:with-param name="base-step-elm" select="$base-step/xpref:signature"/>
      </xsl:call-template>

      <xsl:call-template name="copy-element-if-not-exists">
        <xsl:with-param name="step-identity-elm" select="$step-identity/xpref:summary"/>
        <xsl:with-param name="base-step-elm" select="$base-step/xpref:summary"/>
      </xsl:call-template>

      <xsl:call-template name="copy-element-if-not-exists">
        <xsl:with-param name="step-identity-elm" select="$step-identity/xpref:description"/>
        <xsl:with-param name="base-step-elm" select="$base-step/xpref:description"/>
      </xsl:call-template>

      <xsl:call-template name="copy-element-lists-by-id">
        <xsl:with-param name="step-identity-elms" select="$step-identity/xpref:detail"/>
        <xsl:with-param name="base-step-elms" select="$base-step/xpref:detail"/>
      </xsl:call-template>
      
      <xsl:call-template name="copy-element-lists-by-id">
        <xsl:with-param name="step-identity-elms" select="$step-identity/xpref:example"/>
        <xsl:with-param name="base-step-elms" select="$base-step/xpref:example"/>
      </xsl:call-template>

      <xsl:call-template name="copy-element-if-not-exists">
        <xsl:with-param name="step-identity-elm" select="$step-identity/xpref:step-errors"/>
        <xsl:with-param name="base-step-elm" select="$base-step/xpref:step-errors"/>
      </xsl:call-template>

    </step>

  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template name="copy-element-if-not-exists">
    <xsl:param name="step-identity-elm" as="element()?" required="true"/>
    <xsl:param name="base-step-elm" as="element()?" required="true"/>

    <xsl:choose>
      <xsl:when test="exists($step-identity-elm)">
        <xsl:copy-of select="$step-identity-elm"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$base-step-elm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="copy-element-lists-by-id">
    <!-- For copying the <detail> and <example> stuff. Elements with the same id are considered the same.  -->
    <xsl:param name="step-identity-elms" as="element()*" required="true"/>
    <xsl:param name="base-step-elms" as="element()*" required="true"/>

    <xsl:variable name="step-identity-ids" as="xs:string*" select="$step-identity-elms/@id/string()"/>

    <!-- Copy the details from the base step that are not in the identity: -->
    <xsl:copy-of select="$base-step-elms[not(@id = $step-identity-ids)]"/>

    <!-- Copy everything from the identity but *not* empty elements: -->
    <xsl:copy-of select="$step-identity-elms[exists(node())]"/>

  </xsl:template>

</xsl:stylesheet>
