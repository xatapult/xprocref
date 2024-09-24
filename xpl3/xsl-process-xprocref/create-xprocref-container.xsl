<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.qtv_2nd_5bc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:db="http://docbook.org/ns/docbook" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       TBD
       
       Input is the (normalized and enhanced) XProcRef definition.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-process-text" on-no-match="fail"/>
  <xsl:mode name="mode-process-text-inner-elements" on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/xprocref.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="xprocref-index" as="document-node()" required="true"/>

  <xsl:param name="production-version" as="xs:boolean" required="true"/>

  <xsl:param name="wip" as="xs:boolean" required="true"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="specification" as="document-node()" select="/"/>

  <xsl:variable name="namespace-xdoc" as="xs:string" select="'http://www.xtpxlib.nl/ns/xdoc'"/>
  <xsl:variable name="namespace-docbook" as="xs:string" select="'http://docbook.org/ns/docbook'"/>

  <xsl:variable name="namespaces-leave-unchanged" as="xs:string+" select="($namespace-docbook, $namespace-xdoc)"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create index maps for faster lookups of steps, versions and categories: -->

  <xsl:variable name="version-id-to-elm" as="map(xs:string, element(xpref:version))">
    <xsl:map>
      <xsl:for-each select="$specification/*/xpref:versions/xpref:version">
        <xsl:map-entry key="xs:string(@id)" select="."/>
      </xsl:for-each>
    </xsl:map>
  </xsl:variable>

  <xsl:variable name="step-id-to-elm" as="map(xs:string, element(xpref:step))">
    <xsl:map>
      <xsl:for-each select="$specification/*/xpref:steps/xpref:step">
        <xsl:map-entry key="xs:string(@id)" select="."/>
      </xsl:for-each>
    </xsl:map>
  </xsl:variable>

  <xsl:variable name="category-id-to-elm" as="map(xs:string, element(xpref:category))">
    <xsl:map>
      <xsl:for-each select="$specification/*/xpref:categories/xpref:category">
        <xsl:map-entry key="xs:string(@id)" select="."/>
      </xsl:for-each>
    </xsl:map>
  </xsl:variable>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Latest version info. We need this decide where to put stuff and where top point links to. -->

  <xsl:variable name="latest-version-versionref-elm" as="element(xpref:versionref)" select="($xprocref-index/*/xpref:versionref)[1]"/>
  <xsl:variable name="last-version-id" as="xs:string" select="xs:string($latest-version-versionref-elm/@id)"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Keys for the map returned by local:get-prev-next(): -->

  <xsl:variable name="key-prev" as="xs:integer" select="1"/>
  <xsl:variable name="key-next" as="xs:integer" select="2"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- For the signature conversion: -->

  <xsl:variable name="indent" as="xs:string" select="'  '"/>
  <xsl:variable name="lf" as="xs:string" select="'&#10;'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlcon:document-container timestamp="{current-dateTime()}">

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- All the main pages (home, about, versions overview, etc.): -->

      <xsl:comment> == MAIN PAGES: == </xsl:comment>

      <!-- Home page: -->
      <xsl:call-template name="create-all-steps-for-version-page">
        <xsl:with-param name="versionref-elm" select="$latest-version-versionref-elm"/>
        <xsl:with-param name="href-target" select="local:href-result-file($xpref:name-home-page)"/>
        <xsl:with-param name="is-home-page" select="true()"/>
      </xsl:call-template>

      <!-- Versions overview page: -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="local:href-result-file($xpref:name-versions-overview-page)"/>
        <xsl:with-param name="title" select="'XProc versions'"/>
        <xsl:with-param name="content">
          <db:itemizedlist role="versions-list">
            <xsl:for-each select="$xprocref-index/*/xpref:versionref">
              <!-- Find the version entry in the main document: -->
              <xsl:variable name="version-id" as="xs:string" select="xs:string(@id)"/>
              <xsl:variable name="version-elm" as="element(xpref:version)" select="$version-id-to-elm($version-id)"/>
              <db:listitem>
                <db:para>
                  <db:link
                    xlink:href="{local:href-result-file(if ($version-id eq $last-version-id) then () else $version-id, $xpref:name-version-home-page)}"
                    >Version {$version-elm/@name}</db:link>
                </db:para>
                <xsl:call-template name="process-text">
                  <xsl:with-param name="surrounding-elm" select="$version-elm/xpref:description"/>
                </xsl:call-template>
              </db:listitem>
            </xsl:for-each>
          </db:itemizedlist>
        </xsl:with-param>
      </xsl:call-template>

      <!-- Error codes page: -->
      <xsl:variable name="error-namespace-elm" as="element(xpref:namespace)"
        select="$specification/*/xpref:namespaces/xpref:namespace[xtlc:str2bln(@error-namespace, false())]"/>
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="local:href-result-file($xpref:name-error-codes-overview-page)"/>
        <xsl:with-param name="title" select="'Error codes (all versions)'"/>
        <xsl:with-param name="content">
          <db:para role="break-after">All errors are in the <db:code>{$error-namespace-elm/@uri}</db:code> namespace (recommended prefix:
              <db:code>{$error-namespace-elm/@prefix}</db:code>).</db:para>
          <db:table role="nonumber error-codes-table">
            <db:title/>
            <db:tgroup cols="2">
              <db:thead>
                <db:row>
                  <db:entry>
                    <db:para>Error code</db:para>
                  </db:entry>
                  <db:entry>
                    <db:para>Description</db:para>
                  </db:entry>
                </db:row>
              </db:thead>
              <db:tbody>
                <xsl:for-each select="$specification/*/xpref:errors/xpref:error">
                  <xsl:sort select="xs:string(@code)"/>
                  <xsl:variable name="code" as="xs:string" select="xs:string(@code)"/>
                  <db:row>
                    <db:entry>
                      <db:para>
                        <xsl:attribute name="xml:id" select="xpref:error-code-anchor($code)"/>
                        <db:code>
                          <xsl:value-of select="$code"/>
                        </db:code>
                      </db:para>
                    </db:entry>
                    <db:entry>
                      <xsl:call-template name="process-text">
                        <xsl:with-param name="surrounding-elm" select="xpref:description"/>
                      </xsl:call-template>
                    </db:entry>
                  </db:row>
                </xsl:for-each>
              </db:tbody>
            </db:tgroup>
          </db:table>
        </xsl:with-param>
      </xsl:call-template>

      <!-- Namespaces page: -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="local:href-result-file($xpref:name-namespaces-overview-page)"/>
        <xsl:with-param name="title" select="'Namespaces used (all versions)'"/>
        <xsl:with-param name="content">
          <db:itemizedlist>
            <xsl:for-each select="$specification/*/xpref:namespaces/xpref:namespace">
              <db:listitem>
                <db:para><db:code>{@uri}</db:code> (recommended prefix: <db:code>{@prefix}</db:code>)</db:para>
                <xsl:call-template name="process-text">
                  <xsl:with-param name="surrounding-elm" select="xpref:description"/>
                </xsl:call-template>
              </db:listitem>
            </xsl:for-each>
          </db:itemizedlist>
        </xsl:with-param>
      </xsl:call-template>

      <!-- About page -->
      <xsl:variable name="href-about-page-content" as="xs:string" select="resolve-uri('../../data/about-page.xml', static-base-uri())"/>
      <xsl:variable name="about-page-content" as="element()*" select="doc($href-about-page-content)/*/db:*"/>
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="$xpref:name-about-page"/>
        <xsl:with-param name="title" select="'About XProcRef'"/>
        <xsl:with-param name="content">
          <xsl:sequence select="$about-page-content"/>
          <db:para>&#160;</db:para>
          <db:para role="site-remark">Site published {if ($production-version) then () else ' [TEST VERSION]'}: {xs:string(current-dateTime()) =>
            substring(1, 16) => replace('T', ' ')}</db:para>
        </xsl:with-param>
      </xsl:call-template>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- All the pages for the different versions: -->

      <xsl:apply-templates select="$xprocref-index/*/xpref:versionref"/>

    </xtlcon:document-container>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- PROCESS VERSION: -->

  <xsl:template match="xpref:versionref">

    <xsl:variable name="versionref-elm" as="element(xpref:versionref)" select="."/>
    <xsl:variable name="version-id" as="xs:string" select="xs:string($versionref-elm/@id)"/>
    <xsl:variable name="version-elm" as="element(xpref:version)" select="$version-id-to-elm($version-id)"/>
    <xsl:variable name="version-name" as="xs:string" select="xs:string($version-elm/@name)"/>

    <xsl:comment> == PAGES FOR VERSION {$version-name} == </xsl:comment>

    <!-- Home page for version. Do not produce this for the latest version. We use the home page for this. -->
    <xsl:if test="$version-id ne $last-version-id">
      <xsl:call-template name="create-all-steps-for-version-page">
        <xsl:with-param name="versionref-elm" select="$versionref-elm"/>
        <xsl:with-param name="href-target" select="local:href-result-file($version-id, $xpref:name-version-home-page)"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Categories overview page for version: -->
    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="local:href-result-file($version-id, $xpref:name-categories-overview-page)"/>
      <xsl:with-param name="title" select="'Categories (' || $version-name || ')'"/>
      <xsl:with-param name="content">
        <db:itemizedlist role="category-list">
          <xsl:for-each select="$versionref-elm/xpref:categoryref">
            <xsl:variable name="categoryref-elm" as="element(xpref:categoryref)" select="."/>
            <xsl:variable name="category-id" as="xs:string" select="xs:string($categoryref-elm/@id)"/>
            <xsl:variable name="category-elm" as="element(xpref:category)" select="$category-id-to-elm($category-id)"/>
            <xsl:variable name="category-name" as="xs:string" select="normalize-space($category-elm/@name)"/>
            <db:listitem>
              <db:para>
                <db:link xlink:href="{local:category-page-name($category-id)}">{$category-name}</db:link>
              </db:para>
              <xsl:call-template name="process-text">
                <xsl:with-param name="surrounding-elm" select="$category-elm/xpref:description"/>
              </xsl:call-template>
            </db:listitem>
          </xsl:for-each>
        </db:itemizedlist>
      </xsl:with-param>
      <xsl:with-param name="version-id" select="$version-id"/>
    </xsl:call-template>

    <!-- Page per category for this version: -->
    <xsl:for-each select="$versionref-elm/xpref:categoryref">
      <xsl:variable name="categoryref-elm" as="element(xpref:categoryref)" select="."/>
      <xsl:variable name="category-id" as="xs:string" select="xs:string($categoryref-elm/@id)"/>
      <xsl:variable name="category-elm" as="element(xpref:category)" select="$category-id-to-elm($category-id)"/>
      <xsl:variable name="category-name" as="xs:string" select="normalize-space($category-elm/@name)"/>
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="local:href-result-file($version-id, local:category-page-name($category-id))"/>
        <xsl:with-param name="title" select="'Category: ' || $category-name || ' (' || $version-name || ')'"/>
        <xsl:with-param name="prev-next" select="local:get-prev-next($categoryref-elm)"/>
        <xsl:with-param name="content">
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="$category-elm/xpref:description"/>
          </xsl:call-template>
          <xsl:call-template name="create-stepref-links">
            <xsl:with-param name="steprefs" select="$categoryref-elm/xpref:stepref"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="type" select="$xpref:type-category"/>
        <xsl:with-param name="version-id" select="$version-id"/>
        <xsl:with-param name="ref" select="$category-id"/>
        <xsl:with-param name="name" select="$category-name"/>
      </xsl:call-template>
    </xsl:for-each>

    <!-- All steps for version: -->
    <xsl:apply-templates select="$versionref-elm/xpref:stepref">
      <xsl:with-param name="version-id" as="xs:string" select="$version-id" tunnel="true"/>
    </xsl:apply-templates>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-all-steps-for-version-page">
    <xsl:param name="versionref-elm" as="element(xpref:versionref)" required="true"/>
    <xsl:param name="href-target" as="xs:string" required="true"/>
    <xsl:param name="is-home-page" as="xs:boolean" required="false" select="false()"/>

    <xsl:variable name="version-id" as="xs:string" select="xs:string($versionref-elm/@id)"/>
    <xsl:variable name="version-elm" as="element(xpref:version)" select="$version-id-to-elm($version-id)"/>
    <xsl:variable name="version-name" as="xs:string" select="xs:string($version-elm/@name)"/>
    <xsl:variable name="version-id-for-links" as="xs:string?" select="if ($is-home-page) then $version-id else ()"/>

    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="$href-target"/>
      <xsl:with-param name="title" select="'XProc steps (' || $version-name || ')'"/>
      <xsl:with-param name="content">
        <db:para>Steps for XProc version {$version-name}. You can also view these steps <db:link
            xlink:href="{local:href-result-file($version-id-for-links, $xpref:name-categories-overview-page)}">by category</db:link>.</db:para>
        <db:para/>
        <!-- List all the steps for this version: -->
        <xsl:call-template name="create-stepref-links">
          <xsl:with-param name="steprefs" select="$versionref-elm/xpref:stepref"/>
          <xsl:with-param name="version-id-for-links" select="$version-id-for-links"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="version-id" select="$version-id"/>
    </xsl:call-template>

  </xsl:template>


  <!-- ======================================================================= -->
  <!-- PROCESS A STEP: -->

  <xsl:template match="xpref:stepref">
    <xsl:param name="version-id" as="xs:string" required="true" tunnel="true"/>

    <xsl:variable name="stepref-elm" as="element(xpref:stepref)" select="."/>
    <xsl:variable name="step-id" as="xs:string" select="xs:string($stepref-elm/@id)"/>
    <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
    <xsl:variable name="step-full-name" as="xs:string" select="local:step-full-name($step-id)"/>
    <xsl:variable name="version-name" as="xs:string" select="xs:string($version-id-to-elm($version-id)/@name)"/>

    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="local:href-result-file($version-id, local:step-page-name($step-id))"/>
      <xsl:with-param name="prev-next" select="local:get-prev-next($stepref-elm)"/>
      <xsl:with-param name="title" select="$step-full-name || ' (' || $version-name || ')'"/>
      <xsl:with-param name="test-version-remark" select="'step published: ' || xtlc:str2bln($step-elm/@publish, false())"/>
      <xsl:with-param name="content">
        <!-- The short description to start with: -->
        <db:para>{local:description($step-elm/@short-description)}</db:para>

        <!-- Summary: -->
        <db:sect2>
          <db:title>Summary</db:title>
          <xsl:call-template name="create-step-signature">
            <xsl:with-param name="step-id" select="$step-id"/>
          </xsl:call-template>
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="$step-elm/xpref:summary"/>
          </xsl:call-template>
          <xsl:call-template name="create-step-tables">
            <xsl:with-param name="signature-elm" select="$step-elm/xpref:signature"/>
          </xsl:call-template>
        </db:sect2>

        <!-- The description: -->
        <db:sect2>
          <db:title>Description</db:title>
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="$step-elm/xpref:description"/>
          </xsl:call-template>
        </db:sect2>

        <!-- Any examples: -->
        <xsl:variable name="examples" as="element(xpref:example)*" select="$step-elm/xpref:example"/>
        <xsl:if test="exists($examples)">
          <db:sect2>
            <db:title>Examples</db:title>
            <xsl:for-each select="$examples">
              <db:sect3>
                <xsl:variable name="example-id" as="xs:string?" select="xpref:example-anchor(.)"/>
                <xsl:if test="exists($example-id)">
                  <xsl:attribute name="xml:id" select="$example-id"/>
                </xsl:if>
                <db:title>{@title}</db:title>
                <xsl:call-template name="process-text">
                  <xsl:with-param name="surrounding-elm" select="."/>
                </xsl:call-template>
              </db:sect3>
            </xsl:for-each>
          </db:sect2>
        </xsl:if>

        <!-- Details: -->
        <xsl:variable name="details" as="element(xpref:detail)*" select="$step-elm/xpref:detail"/>
        <xsl:if test="exists($details)">
          <db:sect2>
            <db:title>Additional details</db:title>
            <db:itemizedlist>
              <xsl:for-each select="$details">
                <db:listitem>
                  <xsl:call-template name="process-text">
                    <xsl:with-param name="surrounding-elm" select="."/>
                  </xsl:call-template>
                </db:listitem>
              </xsl:for-each>
            </db:itemizedlist>
          </db:sect2>
        </xsl:if>

        <!-- Errors: -->
        <xsl:variable name="step-errors" as="element(xpref:step-error)*" select="$step-elm/xpref:step-errors/xpref:step-error"/>
        <xsl:if test="exists($step-errors)">
          <xsl:variable name="href-error-codes-page" as="xs:string" select="xpref:href-combine('..', (), $xpref:name-error-codes-overview-page)"/>
          <db:sect2>
            <db:title>Errors raised</db:title>
            <db:table role="nonumber error-codes-table">
              <db:title/>
              <db:tgroup cols="2">
                <db:thead>
                  <db:row>
                    <db:entry>
                      <db:para>Error code</db:para>
                    </db:entry>
                    <db:entry>
                      <db:para>Description</db:para>
                    </db:entry>
                  </db:row>
                </db:thead>
                <db:tbody>
                  <xsl:for-each select="$step-errors">
                    <xsl:sort select="xs:string(@code)"/>
                    <xsl:variable name="code" as="xs:string" select="xs:string(@code)"/>
                    <db:row>
                      <db:entry>
                        <db:para>
                          <xsl:attribute name="xml:id" select="xpref:error-code-anchor($code)"/>
                          <db:link xlink:href="{$href-error-codes-page}#{xpref:error-code-anchor($code)}">
                            <db:code>
                              <xsl:value-of select="$code"/>
                            </db:code>
                          </db:link>
                        </db:para>
                      </db:entry>
                      <db:entry>
                        <xsl:choose>
                          <xsl:when test="exists(xpref:description)">
                            <xsl:call-template name="process-text">
                              <xsl:with-param name="surrounding-elm" select="xpref:description"/>
                            </xsl:call-template>
                          </xsl:when>
                          <xsl:otherwise>
                            <!-- Get the description from the general error codes list: -->
                            <xsl:call-template name="process-text">
                              <xsl:with-param name="surrounding-elm"
                                select="$specification/*/xpref:errors/xpref:error[@code eq $code]/xpref:description"/>
                            </xsl:call-template>
                          </xsl:otherwise>
                        </xsl:choose>
                      </db:entry>
                    </db:row>
                  </xsl:for-each>
                </db:tbody>
              </db:tgroup>
            </db:table>
          </db:sect2>
        </xsl:if>

        <!-- Reference information: -->
        <db:sect2>
          <db:title>Reference information</db:title>

          <xsl:variable name="step-is-required" as="xs:boolean" select="xtlc:str2bln($step-elm/@required, false())"/>
          <xsl:variable name="required-text" as="xs:string">
            <xsl:choose>
              <xsl:when test="$step-is-required">
                <xsl:sequence select="'This is a required step (an XProc ' || $version-name || ' processor must support this).'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="'This is a non-required step (an XProc ' || $version-name || ' processor does not have to support this).'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="version-link" as="xs:string"
            select="if ($version-id eq $last-version-id) then xpref:href-combine('..', (), $xpref:name-home-page) else xpref:href-combine((), $xpref:name-version-home-page)"/>
          <db:para>This description of the <db:code role="step">{$step-full-name}</db:code> step is for XProc version: <db:link
              xlink:href="{$version-link}">{$version-name}</db:link>. {$required-text}</db:para>

          <db:para>The formal specification for the <db:step>{$step-full-name}</db:step> step can be found <db:link
              xlink:href="{$step-elm/@href-specification}" role="newpage">here</db:link>.</db:para>

          <xsl:variable name="category-refs" as="element(xpref:categoryref)*" select="$stepref-elm/xpref:categoryref"/>
          <xsl:choose>
            <xsl:when test="count($category-refs) eq 1">
              <xsl:variable name="category-id" as="xs:string" select="xs:string($category-refs[1]/@id)"/>
              <db:para>The <db:step>{$step-full-name}</db:step> step is part of category: <db:link
                  xlink:href="{local:category-page-name($category-id)}">{$category-id-to-elm($category-id)/@name}</db:link>.</db:para>
            </xsl:when>
            <xsl:when test="count($category-refs) gt 1">
              <db:para>The <db:step>{$step-full-name}</db:step> step is part of categories:</db:para>
              <db:itemizedlist>
                <xsl:for-each select="$category-refs">
                  <xsl:variable name="category-id" as="xs:string" select="xs:string(@id)"/>
                  <db:listitem>
                    <db:para>
                      <db:link xlink:href="{local:category-page-name($category-id)}">{$category-id-to-elm($category-id)/@name}</db:link>
                    </db:para>
                  </db:listitem>
                </xsl:for-each>
              </db:itemizedlist>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>

          <xsl:variable name="other-versionrefs" as="element(xpref:other-versionref)*" select="$stepref-elm/xpref:other-versionref"/>
          <xsl:if test="exists($other-versionrefs)">
            <db:para>The <db:step>{$step-full-name}</db:step> step is also present in version{if (count($other-versionrefs) eq 1) then () else 's'}:
                <xsl:for-each select="$other-versionrefs">
                <xsl:variable name="other-version-id" as="xs:string" select="xs:string(@id)"/>
                <xsl:variable name="other-version-elm" as="element(xpref:version)" select="$version-id-to-elm($other-version-id)"/>
                <xsl:variable name="other-version-name" as="xs:string" select="xs:string($other-version-elm/@name)"/>
                <db:link xlink:href="{xpref:href-combine('..', $other-version-name, local:step-page-name(xs:string(@step-id)))}"
                  >{$other-version-name}</db:link>
                <xsl:if test="position() ne last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:text>.</xsl:text>
              </xsl:for-each>
            </db:para>
          </xsl:if>

        </db:sect2>

      </xsl:with-param>
      <xsl:with-param name="type" select="$xpref:type-step"/>
      <xsl:with-param name="version-id" select="$version-id"/>
      <xsl:with-param name="ref" select="$step-full-name"/>
      <xsl:with-param name="name" select="$step-full-name"/>
    </xsl:call-template>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-step-signature">
    <xsl:param name="step-id" as="xs:string" required="true"/>

    <xsl:variable name="signature-elm" as="element(xpref:signature)" select="$step-id-to-elm($step-id)/xpref:signature"/>

    <xsl:variable name="lines" as="xs:string+">
      <xsl:sequence select="'&lt;p:declare-step type=&quot;' || local:step-full-name($step-id) || '&quot;&gt;'"/>
      <!-- Primary ports: -->
      <xsl:for-each select="($signature-elm/(xpref:input | xpref:output))[xs:boolean(@primary)]">
        <xsl:sort select="local-name(.)"/>
        <xsl:variable name="add-empty" as="xs:boolean" select="exists(self::xpref:input) and xtlc:str2bln(@empty, false())"/>
        <xsl:sequence select="local:declare-step-sub-element-to-string(., (@port, @primary), (), $add-empty)"/>
      </xsl:for-each>
      <!-- Non-primary ports: -->
      <xsl:for-each select="($signature-elm/(xpref:input | xpref:output))[not(xs:boolean(@primary))]">
        <xsl:sort select="local-name(.)"/>
        <xsl:sort select="xs:string(@port)"/>
        <xsl:variable name="add-empty" as="xs:boolean" select="exists(self::xpref:input) and xtlc:str2bln(@empty, false())"/>
        <xsl:sequence select="local:declare-step-sub-element-to-string(., (@port, @primary), (), $add-empty)"/>
      </xsl:for-each>
      <!-- Options: -->
      <xsl:for-each select="$signature-elm/xpref:option">
        <xsl:sort select="string(@required)" order="descending"/>
        <xsl:sort select="xs:string(@name)"/>
        <xsl:sequence select="local:declare-step-sub-element-to-string(., (@name, @as, @required, @select), (@subtype))"/>
      </xsl:for-each>
      <xsl:sequence select="'&lt;/p:declare-step&gt;'"/>
    </xsl:variable>

    <db:programlisting role="step-signature">
      <xsl:value-of select="string-join($lines, $lf)"/>
    </db:programlisting>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:declare-step-sub-element-to-string" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="attributes" as="attribute()*">
      <!-- Attributes in order of appearance. All other attributes are alphabetically sorted after these.-->
    </xsl:param>
    <xsl:param name="ignore-attributes" as="attribute()*"/>
    <xsl:param name="add-empty" as="xs:boolean"/>

    <xsl:variable name="parts" as="xs:string+">
      <xsl:sequence select="$indent || '&lt;' || local-name($elm)"/>
      <xsl:for-each select="$attributes">
        <xsl:sequence select="' ' || xtlc:att2str(.)"/>
      </xsl:for-each>
      <xsl:for-each select="$elm/@* except ($attributes, $ignore-attributes)">
        <xsl:sort select="local-name(.)"/>
        <xsl:sequence select="' ' || xtlc:att2str(.)"/>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="$add-empty">
          <xsl:sequence select="'&gt;' || $lf"/>
          <xsl:sequence select="$indent || $indent || '&lt;p:empty/&gt;' || $lf"/>
          <xsl:sequence select="$indent || '&lt;' || local-name($elm) || '/&gt;'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'/&gt;'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="string-join($parts)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:declare-step-sub-element-to-string" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="attributes" as="attribute()*"/>
    <xsl:param name="ignore-attributes" as="attribute()*"/>
    <xsl:sequence select="local:declare-step-sub-element-to-string($elm, $attributes, $ignore-attributes, false())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:declare-step-sub-element-to-string" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="attributes" as="attribute()*"/>
    <xsl:sequence select="local:declare-step-sub-element-to-string($elm, $attributes, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-step-tables">
    <xsl:param name="signature-elm" as="element(xpref:signature)" required="true"/>

    <!-- Ports: -->
    <db:para role="table-header">Ports:</db:para>
    <db:table role="nonumber ports-table">
      <db:title/>
      <db:tgroup cols="6">
        <db:thead>
          <db:row>
            <db:entry>
              <db:para>Type</db:para>
            </db:entry>
            <db:entry>
              <db:para>Port</db:para>
            </db:entry>
            <db:entry>
              <db:para>Primary?</db:para>
            </db:entry>
            <db:entry>
              <db:para>Content types</db:para>
            </db:entry>
            <db:entry>
              <db:para>Seq?</db:para>
            </db:entry>
            <db:entry>
              <db:para>Description</db:para>
            </db:entry>
          </db:row>
        </db:thead>
        <db:tbody>
          <!-- Primary ports: -->
          <xsl:for-each select="($signature-elm/(xpref:input | xpref:output))[xs:boolean(@primary)]">
            <xsl:sort select="local-name(.)"/>
            <xsl:call-template name="create-port-table-row"/>
          </xsl:for-each>
          <!-- Non-primary ports: -->
          <xsl:for-each select="($signature-elm/(xpref:input | xpref:output))[not(xs:boolean(@primary))]">
            <xsl:sort select="local-name(.)"/>
            <xsl:sort select="xs:string(@port)"/>
            <xsl:call-template name="create-port-table-row"/>
          </xsl:for-each>
        </db:tbody>
      </db:tgroup>
    </db:table>

    <!-- Options (if any): -->
    <xsl:variable name="option-elms" as="element(xpref:option)*" select="$signature-elm/xpref:option"/>
    <xsl:if test="exists($option-elms)">
      <xsl:variable name="has-selects" as="xs:boolean" select="exists($option-elms/@select)"/>
      <db:para role="table-header">Options:</db:para>
      <db:table role="nonumber options-table">
        <db:title/>
        <db:tgroup cols="6">
          <db:thead>
            <db:row>
              <db:entry>
                <db:para>Name</db:para>
              </db:entry>
              <db:entry>
                <db:para>Type</db:para>
              </db:entry>
              <db:entry>
                <db:para>Req?</db:para>
              </db:entry>
              <xsl:if test="$has-selects">
                <db:entry>
                  <db:para>Default</db:para>
                </db:entry>
              </xsl:if>
              <db:entry>
                <db:para>Description</db:para>
              </db:entry>
            </db:row>
          </db:thead>
          <db:tbody>

            <xsl:for-each select="$option-elms">
              <xsl:sort select="string(@required)" order="descending"/>
              <xsl:sort select="xs:string(@name)"/>
              <db:row>
                <db:entry>
                  <db:para>
                    <db:code>
                      <xsl:value-of select="@name"/>
                    </db:code>
                  </db:para>
                </db:entry>
                <db:entry>
                  <db:para>
                    <db:code>
                      <xsl:value-of select="@as"/>
                    </db:code>
                    <xsl:if test="exists(@subtype)">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="local:option-subtype-description(@subtype)"/>
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                  </db:para>
                </db:entry>
                <db:entry>
                  <db:para>
                    <db:code>
                      <xsl:value-of select="@required"/>
                    </db:code>
                  </db:para>
                </db:entry>
                <xsl:if test="$has-selects">
                  <db:entry>
                    <db:para>
                      <db:code>
                        <xsl:value-of select="(local:polish-default-option-value(@select), '&#160;')[1]"/>
                      </db:code>
                    </db:para>
                  </db:entry>
                </xsl:if>
                <db:entry>
                  <xsl:call-template name="process-text">
                    <xsl:with-param name="surrounding-elm" select="xpref:description"/>
                  </xsl:call-template>
                </db:entry>
              </db:row>
            </xsl:for-each>
          </db:tbody>
        </db:tgroup>
      </db:table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-port-table-row">
    <xsl:param name="port-elm" as="element()" required="false" select="."/>

    <db:row>
      <db:entry>
        <db:para>
          <db:code>
            <xsl:value-of select="local-name($port-elm)"/>
          </db:code>
        </db:para>
      </db:entry>
      <db:entry>
        <db:para>
          <db:code>
            <xsl:value-of select="$port-elm/@port"/>
          </db:code>
        </db:para>
      </db:entry>
      <db:entry>
        <db:para>
          <db:code>
            <xsl:value-of select="$port-elm/@primary"/>
          </db:code>
        </db:para>
      </db:entry>
      <db:entry>
        <db:para>
          <db:code>
            <xsl:value-of select="$port-elm/@content-types"/>
          </db:code>
        </db:para>
      </db:entry>
      <db:entry>
        <db:para>
          <db:code>
            <xsl:value-of select="$port-elm/@sequence"/>
          </db:code>
        </db:para>
      </db:entry>
      <db:entry>
        <xsl:call-template name="process-text">
          <xsl:with-param name="surrounding-elm" select="$port-elm/xpref:description"/>
        </xsl:call-template>
      </db:entry>
    </db:row>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- CREATE DOCBOOK ARTICLES: -->

  <xsl:template name="create-docbook-article">
    <!-- Creates a DocBook article inside a xtpxlib container document. -->
    <xsl:param name="href-target" as="xs:string" required="true"/>
    <xsl:param name="title" as="xs:string" required="true"/>
    <xsl:param name="prev-next" as="map(xs:integer, xs:string)" required="false" select="map{}"/>
    <xsl:param name="content" as="node()*" required="true"/>
    <xsl:param name="type" as="xs:string?" required="false" select="()"/>
    <xsl:param name="version-id" as="xs:string?" required="false" select="()"/>
    <xsl:param name="ref" as="xs:string?" required="false" select="()">
      <!-- This is the string/name to find it back. For instance, the step name of the category id. -->
    </xsl:param>
    <xsl:param name="name" as="xs:string?" required="false" select="()">
      <!-- The name to use when this document is linked to. -->
    </xsl:param>
    <xsl:param name="test-version-remark" as="xs:string?" required="false" select="()"/>

    <xsl:variable name="prev-marker" as="node()*">
      <xsl:if test="map:contains($prev-next, $key-prev)">
        <db:link xlink:href="{$prev-next($key-prev)}">
          <db:inlinemediaobject role="next-prev-marker">
            <db:imageobject>
              <db:imagedata fileref="../images/previous.png" width="1.5%"/>
            </db:imageobject>
          </db:inlinemediaobject>
        </db:link>
        <xsl:text>&#160;</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="next-marker" as="node()*">
      <xsl:if test="map:contains($prev-next, $key-next)">
        <xsl:text>&#160;</xsl:text>
        <db:link xlink:href="{$prev-next($key-next)}">
          <db:inlinemediaobject role="next-prev-marker">
            <db:imageobject>
              <db:imagedata fileref="../images/next.png" width="1.5%"/>
            </db:imageobject>
          </db:inlinemediaobject>
        </db:link>
      </xsl:if>
    </xsl:variable>

    <!-- Remark: We set the content type to text/html, although it isn't yet XHTML. But it will very soon be... -->
    <xtlcon:document href-target="{$href-target}" content-type="text/html">
      <xsl:if test="exists($type)">
        <xsl:attribute name="type" select="$type"/>
      </xsl:if>
      <xsl:if test="exists($version-id)">
        <xsl:attribute name="version-id" select="$version-id"/>
      </xsl:if>
      <xsl:if test="exists($ref)">
        <xsl:attribute name="ref" select="$ref"/>
      </xsl:if>
      <xsl:if test="exists($name)">
        <xsl:attribute name="name" select="$name"/>
      </xsl:if>

      <db:article version="5.0">
        <db:info>
          <db:title/>
        </db:info>
        <xsl:if test="$wip">
          <db:para role="page-banner">This site is work in progress and therefore incomplete yet.</db:para>
        </xsl:if>
        <xsl:if test="not($production-version)">
          <db:para role="page-banner">You are looking at the TEST version!{if (exists($test-version-remark)) then (' (' || $test-version-remark ||
            ')') else ()}</db:para>
        </xsl:if>
        <db:sect1>
          <db:title>
            <xsl:copy-of select="$prev-marker" copy-namespaces="false"/>
            <xsl:value-of select="$title"/>
            <xsl:copy-of select="$next-marker" copy-namespaces="false"/>
          </db:title>
          <xsl:copy-of select="$content"/>
        </db:sect1>
      </db:article>
    </xtlcon:document>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- CREATE STEPREF LINKS: -->

  <xsl:template name="create-stepref-links">
    <xsl:param name="steprefs" as="element(xpref:stepref)*" required="true"/>
    <xsl:param name="version-id-for-links" as="xs:string?" required="false" select="()"/>

    <xsl:variable name="step-anchor-prefix" as="xs:string" select="'steps_'"/>

    <!-- Create a map with the referenced steps sorted on first character, in a map(first-character, sequence of step-ids) -->
    <xsl:variable name="grouped-referenced-steps" as="map(xs:string, xs:string+)">
      <xsl:map>
        <xsl:for-each-group select="$steprefs" group-by="local:first-step-name-character(xs:string(@id))">
          <xsl:map-entry key="current-grouping-key()" select="for $stepref in current-group() return xs:string($stepref/@id)"/>
        </xsl:for-each-group>
      </xsl:map>
    </xsl:variable>

    <xsl:variable name="group-by-start-character" as="xs:boolean" select="map:size($grouped-referenced-steps) gt 1"/>

    <!-- Create character choose list: -->
    <xsl:if test="$group-by-start-character">
      <db:para role="step-start-character-list">
        <xsl:for-each select="map:keys($grouped-referenced-steps)">
          <xsl:sort select="."/>
          <xsl:variable name="current-character" as="xs:string" select="."/>
          <db:xref linkend="{$step-anchor-prefix || $current-character}"/>
          <xsl:if test="position() ne last()">
            <xsl:text>&#160; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </db:para>
    </xsl:if>

    <!-- Now create a section for every start character (or un-grouped): -->
    <xsl:choose>
      <xsl:when test="$group-by-start-character">
        <xsl:for-each select="map:keys($grouped-referenced-steps)">
          <xsl:sort select="."/>
          <xsl:variable name="current-character" as="xs:string" select="."/>
          <db:sect2>
            <xsl:attribute name="xml:id" select="$step-anchor-prefix || $current-character"/>
            <db:title role="step-list-start-character">{$current-character}</db:title>
            <xsl:call-template name="create-steps-list">
              <xsl:with-param name="step-ids" select="$grouped-referenced-steps($current-character)"/>
              <xsl:with-param name="version-id-for-links" select="$version-id-for-links"/>
            </xsl:call-template>
          </db:sect2>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="create-steps-list">
          <xsl:with-param name="step-ids" select="for $stepref in $steprefs return xs:string($stepref/@id)"/>
          <xsl:with-param name="version-id-for-links" select="$version-id-for-links"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-steps-list">
    <xsl:param name="step-ids" as="xs:string*" required="true"/>
    <xsl:param name="version-id-for-links" as="xs:string?" required="false" select="()"/>

    <db:itemizedlist role="step-list">
      <xsl:for-each select="$step-ids">
        <xsl:variable name="step-id" as="xs:string" select="."/>
        <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
        <xsl:variable name="step-short-description" as="xs:string" select="local:description($step-elm/@short-description)"/>
        <db:listitem>
          <db:para><db:link xlink:href="{local:href-result-file($version-id-for-links, local:step-page-name($step-id))}"
              >{local:step-full-name($step-id)}</db:link> - {$step-short-description}</db:para>
        </db:listitem>
      </xsl:for-each>
    </db:itemizedlist>

  </xsl:template>


  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:first-step-name-character" as="xs:string">
    <xsl:param name="step-id" as="xs:string"/>
    <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
    <xsl:sequence select="xs:string($step-elm/@name) => substring(1, 1) => upper-case()"/>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- PROCESS TEXT: -->

  <xsl:template name="process-text">
    <xsl:param name="surrounding-elm" as="element()" required="false" select="."/>
    <xsl:apply-templates mode="mode-process-text" select="$surrounding-elm/node()"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[normalize-space(.) ne '']" mode="mode-process-text">
    <!-- This is text at the main level, surround it with Markdown markers: -->
    <xdoc:MARKDOWN>
      <xsl:copy/>
    </xdoc:MARKDOWN>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="mode-process-text">
    <!-- An element at top level. This element and its children must be converted to DocBook, but carefully! -->
    <xsl:apply-templates mode="mode-process-text-inner-elements" select="."/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" priority="-1000" mode="mode-process-text">
    <!-- Discard anything else at top level. -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*[not(namespace-uri(.) = $namespaces-leave-unchanged)]" mode="mode-process-text-inner-elements">
    <xsl:element name="db:{local-name(.)}">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()" mode="mode-process-text-inner-elements">
    <!-- Discard... -->
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- FILE NAME SUPPORT: -->

  <xsl:function name="local:href-result-file" as="xs:string">
    <xsl:param name="version-id" as="xs:string?"/>
    <xsl:param name="filename" as="xs:string"/>

    <xsl:variable name="version-name" as="xs:string?">
      <xsl:if test="exists($version-id)">
        <xsl:sequence select="xs:string($version-id-to-elm($version-id)/@name) "/>
      </xsl:if>
    </xsl:variable>
    <xsl:sequence select="xpref:href-combine($version-name, $filename)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:href-result-file" as="xs:string">
    <xsl:param name="filename" as="xs:string"/>
    <xsl:sequence select="local:href-result-file((), $filename)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:step-page-name" as="xs:string">
    <xsl:param name="step-id" as="xs:string"/>

    <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
    <xsl:sequence select="string-join(($step-elm/@namespace-prefix, $step-elm/@name, $xpref:page-extension), '.')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:category-page-name" as="xs:string">
    <xsl:param name="category-id" as="xs:string"/>

    <xsl:variable name="category-elm" as="element(xpref:category)" select="$category-id-to-elm($category-id)"/>
    <xsl:sequence
      select="(xs:string($category-elm/@name) => normalize-space() => replace('\s+', '_') => xtlc:str2filename-safe()) || '.' || $xpref:page-extension"
    />
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- OTHER SUPPORT: -->

  <xsl:function name="local:step-full-name" as="xs:string">
    <xsl:param name="step-id" as="xs:string"/>

    <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
    <xsl:sequence select="$step-elm/@namespace-prefix || ':' || $step-elm/@name"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-prev-next" as="map(xs:integer, xs:string)">
    <!-- Returns a map with a previous/next link. -->
    <xsl:param name="elm" as="element()"/>

    <xsl:variable name="elm-name" as="xs:string" select="local-name($elm)"/>
    <xsl:variable name="next" as="element()?" select="($elm/following-sibling::*[local-name(.) eq $elm-name])[1]"/>
    <xsl:variable name="prev" as="element()?" select="($elm/preceding-sibling::*[local-name(.) eq $elm-name])[last()]"/>
    <xsl:map>
      <xsl:if test="exists($prev)">
        <xsl:map-entry key="$key-prev" select="local:get-link($prev)"/>
      </xsl:if>
      <xsl:if test="exists($next)">
        <xsl:map-entry key="$key-next" select="local:get-link($next)"/>
      </xsl:if>
    </xsl:map>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-link" as="xs:string">
    <!-- Gets the link/page-name to a page produced for some elements. Used by local:get-prev-next(). -->
    <xsl:param name="elm" as="element()"/>

    <xsl:choose>
      <xsl:when test="exists($elm/self::xpref:stepref)">
        <xsl:sequence select="local:step-page-name($elm/@id)"/>
      </xsl:when>
      <xsl:when test="exists($elm/self::xpref:categoryref)">
        <xsl:sequence select="local:category-page-name($elm/@id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="($xtlc:internal-error-prompt, 'Cannot create a page link from element ', $elm)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:description" as="xs:string">
    <!-- Prepares a description string for output. Normalizes it and makes sure it ends with a dot. -->
    <xsl:param name="description" as="xs:string"/>

    <xsl:variable name="description-normalized" as="xs:string" select="normalize-space($description)"/>
    <xsl:variable name="ends-with-dot" as="xs:boolean" select="ends-with($description-normalized, '.')"/>
    <xsl:sequence select="$description-normalized || (if ($ends-with-dot) then () else '.')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:option-subtype-description" as="xs:string?">
    <xsl:param name="subtype" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="empty($subtype)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="$subtype eq 'XSLTSelectionPattern'">
        <xsl:sequence select="'XSLT selection pattern'"/>
      </xsl:when>
      <xsl:when test="$subtype eq 'XPathExpression'">
        <xsl:sequence select="'XPath expression'"/>
      </xsl:when>
      <xsl:when test="$subtype eq 'XPathSequenceType'">
        <xsl:sequence select="'XPath sequence type'"/>
      </xsl:when>
      <xsl:when test="$subtype eq 'ContentType'">
        <xsl:sequence select="'MIME type'"/>
      </xsl:when>
      <xsl:when test="$subtype eq 'ContentTypes'">
        <xsl:sequence select="'list of MIME types'"/>
      </xsl:when>
      <xsl:when test="$subtype eq 'RegularExpression'">
        <xsl:sequence select="'XPath regular expression'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Unrecognized option subtype: ', xtlc:q($subtype))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:polish-default-option-value" as="xs:string?">
    <!-- Takes a default option value and polishes it: Removes starting/trailing single quotes, 
      removes the brackets on true() and false(), etc. -->
    <xsl:param name="value" as="xs:string?"/>

    <xsl:variable name="value-1" as="xs:string" select="normalize-space($value)"/>
    <xsl:choose>
      <xsl:when test="empty($value)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="starts-with($value-1, '''') and ends-with($value-1, '''')">
        <xsl:sequence select="substring($value-1, 2, string-length($value-1) - 2)"/>
      </xsl:when>
      <xsl:when test="$value-1 eq 'true()'">
        <xsl:sequence select="'true'"/>
      </xsl:when>
      <xsl:when test="$value-1 eq 'false()'">
        <xsl:sequence select="'false'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$value-1"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>
