<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.oxf_4nc_wbc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Performs some fixups on the (DocBook) texts in the container.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="db:port | db:option | db:step | db:property">
    <code role="{local-name(.)}">
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:step-error-ref">
    <xsl:try>
      <xsl:variable name="code" as="xs:string" select="xs:string(@code)"/>
      <code>
        <link xlink:href="#{xpref:error-code-anchor($code)}">{$code}</link>
      </code>

      <xsl:catch>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Could not dereference ', .)"/>
        </xsl:call-template>
      </xsl:catch>
    </xsl:try>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:step-ref | db:category-ref">

    <xsl:try>
      <xsl:variable name="document-elm" as="element(xtlcon:document)" select="ancestor::xtlcon:document"/>
      <xsl:variable name="current-version-id" as="xs:string" select="xs:string($document-elm/@version-id)"/>
      <xsl:variable name="current-href-target" as="xs:string" select="xs:string($document-elm/@href-target)"/>

      <xsl:variable name="referred-type" as="xs:string" select="if (exists(self::db:step-ref)) then $xpref:type-step else $xpref:type-category"/>
      <xsl:variable name="referred-ref" as="xs:string" select="if ($referred-type eq $xpref:type-step) then xs:string(@name) else xs:string(@idref)"/>
      <xsl:variable name="referred-version-id" as="xs:string" select="xs:string((@version-id, $current-version-id)[1])"/>

      <xsl:variable name="referred-document-elm" as="element(xtlcon:document)"
        select="/*/xtlcon:document[@type eq $referred-type][@ref eq $referred-ref][@version-id eq $referred-version-id][1]"/>
      <xsl:variable name="referred-href-target" as="xs:string" select="xs:string($referred-document-elm/@href-target)"/>
      <xsl:variable name="referred-name" as="xs:string" select="xs:string(($referred-document-elm/@name, $referred-ref)[1])"/>

      <xsl:variable name="link-elm" as="element(db:link)">
        <link xlink:href="{xtlc:href-relative($current-href-target, $referred-href-target)}">{$referred-name}</link>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$referred-type eq $xpref:type-step">
          <code role="step">
            <xsl:sequence select="$link-elm"/>
          </code>
        </xsl:when>
        <xsl:otherwise> 
          <xsl:sequence select="$link-elm"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:catch>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Could not dereference ', .)"/>
        </xsl:call-template>
      </xsl:catch>
    </xsl:try>

  </xsl:template>

</xsl:stylesheet>
