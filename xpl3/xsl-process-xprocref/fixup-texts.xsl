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

  <xsl:template match="db:fragment">
    <!-- Just unwrap -->
    <xsl:apply-templates/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:port | db:option | db:property">
    <code role="{local-name(.)}">
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:step">
    <xsl:choose>
      <xsl:when test="empty(node())">
        <!-- Refers to this particular step: -->
        <xsl:variable name="container-document-elm" as="element(xtlcon:document)" select="ancestor::xtlcon:document"/>
        <code role="{local-name(.)}">
          <xsl:value-of select="$container-document-elm/@name"/>
        </code>
      </xsl:when>
      <xsl:otherwise>
        <code role="{local-name(.)}">
          <xsl:apply-templates/>
        </code>
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template match="db:*[matches(local-name(.), 'sect[0-9]+')][empty(@xml:id)]">
    <!-- These are used for ToCs and must have an identifier. -->
    <xsl:copy>
      <xsl:attribute name="xml:id" select="local-name(.) || '-' || generate-id(.)"/>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:section">
    <!-- Change a <section> element into a numbered one (<sect…>) or a bridgehead if nested too deep: -->
    <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*[matches(local-name(.), 'section|sect[0-9]+')])"/>
    <xsl:choose>
      <xsl:when test="$level le $xpref:max-section-level">
        <xsl:variable name="element-name" as="xs:string" select="'sect' || $level"/>
        <xsl:element name="{$element-name}">
          <xsl:if test="empty(@xml:id)">
            <xsl:attribute name="xml:id" select="$element-name || '-' || generate-id(.)"/>
          </xsl:if>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <db:bridgehead>
          <xsl:copy-of select="db:title/node()"/>
        </db:bridgehead>
        <xsl:apply-templates select="node() except db:title"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:example-doc">
    <xsl:variable name="href" as="xs:string" select="xs:string(@href)"/>
    <db:programlisting xml:space="preserve"><xsl:value-of select="unparsed-text($href)"/></db:programlisting>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- REFERENCES: -->

  <xsl:template match="db:step-ref | db:category-ref">

    <xsl:try>
      <xsl:variable name="container-document-elm" as="element(xtlcon:document)" select="ancestor::xtlcon:document"/>
      <xsl:variable name="current-version-id" as="xs:string" select="xs:string($container-document-elm/@version-id)"/>
      <xsl:variable name="current-href-target" as="xs:string" select="xs:string($container-document-elm/@href-target)"/>

      <xsl:variable name="referred-type" as="xs:string" select="if (exists(self::db:step-ref)) then $xpref:type-step else $xpref:type-category"/>
      <xsl:variable name="referred-ref" as="xs:string" select="if ($referred-type eq $xpref:type-step) then xs:string(@name) else xs:string(@idref)"/>
      <xsl:variable name="referred-version-id" as="xs:string" select="xs:string((@version-id, $current-version-id)[1])"/>

      <xsl:variable name="referred-container-document-elm" as="element(xtlcon:document)"
        select="/*/xtlcon:document[@type eq $referred-type][@ref eq $referred-ref][@version-id eq $referred-version-id][1]"/>
      <xsl:variable name="referred-href-target" as="xs:string" select="xs:string($referred-container-document-elm/@href-target)"/>
      <xsl:variable name="referred-name" as="xs:string" select="xs:string(($referred-container-document-elm/@name, $referred-ref)[1])"/>

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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:example-ref">

    <xsl:try>
      <xsl:variable name="current-container-document-elm" as="element(xtlcon:document)" select="ancestor::xtlcon:document"/>
      <xsl:variable name="current-version-id" as="xs:string" select="xs:string($current-container-document-elm/@version-id)"/>
      <xsl:variable name="current-step-name" as="xs:string" select="xs:string($current-container-document-elm/@name)"/>
      <xsl:variable name="referred-step-name" as="xs:string" select="xs:string((@step-name, $current-step-name)[1])"/>
      <xsl:variable name="referred-example-id" as="xs:string" select="xs:string(@idref)"/>
      <xsl:variable name="in-own-step" as="xs:boolean" select="$referred-step-name eq $current-step-name"/>
      <xsl:variable name="referred-container-document-elm" as="element(xtlcon:document)"
        select="if ($in-own-step) then $current-container-document-elm else /*/xtlcon:document[@type eq $xpref:type-step][@name eq $referred-step-name][1]"/>
      <xsl:variable name="referred-anchor" as="xs:string"
        select="xpref:example-anchor($referred-step-name, $current-version-id, $referred-example-id)"/>
      <xsl:variable name="referred-example-section" as="element()" select="$referred-container-document-elm//db:*[@xml:id eq $referred-anchor]"/>

      <xsl:variable name="href-link-to-target" as="xs:string?">
        <xsl:if test="not($in-own-step)">
          <xsl:variable name="current-href-target" as="xs:string" select="xs:string($current-container-document-elm/@href-target)"/>
          <xsl:variable name="referred-href-target" as="xs:string" select="xs:string($referred-container-document-elm/@href-target)"/>
          <xsl:sequence select="xtlc:href-relative($current-href-target, $referred-href-target)"/>
        </xsl:if>
      </xsl:variable>

      <xsl:text>&#x201c;</xsl:text>
      <link xlink:href="{$href-link-to-target}#{$referred-anchor}">{normalize-space($referred-example-section/db:title)}</link>
      <xsl:text>&#x201d;</xsl:text>
      <xsl:if test="not($in-own-step)">
        <xsl:text> in step </xsl:text>
        <code role="step">
          <link xlink:href="{$href-link-to-target}">{$referred-step-name}</link>
        </code>
      </xsl:if>

      <xsl:catch>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Could not dereference ', .)"/>
        </xsl:call-template>
      </xsl:catch>
    </xsl:try>

  </xsl:template>


</xsl:stylesheet>
