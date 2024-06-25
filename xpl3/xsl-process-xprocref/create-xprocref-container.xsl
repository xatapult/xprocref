<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.qtv_2nd_5bc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:db="http://docbook.org/ns/docbook" xmlns:xpref="http://www.xtpxlib.nl/ns/xprocref"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       TBD DESCR
       
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
  <!-- Keys for the map returned by local:get-prev-next(): -->

  <xsl:variable name="key-prev" as="xs:integer" select="1"/>
  <xsl:variable name="key-next" as="xs:integer" select="2"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlcon:document-container timestamp="{current-dateTime()}">

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- All the main pages (home, about, versions overview, etc.): -->

      <xsl:comment> == MAIN PAGES: == </xsl:comment>

      <!-- Home page: -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="local:href-result-file($xpref:name-home-page)"/>
        <xsl:with-param name="title" select="'XProcRef home'"/>
        <xsl:with-param name="content">
          <db:para>TBD</db:para>
        </xsl:with-param>
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
                  <db:link xlink:href="{local:href-result-file($version-id, $xpref:name-version-home-page)}">Version {$version-elm/@name}</db:link>
                </db:para>
                <xsl:call-template name="process-text">
                  <xsl:with-param name="surrounding-elm" select="$version-elm/xpref:description"/>
                </xsl:call-template>
              </db:listitem>
            </xsl:for-each>
          </db:itemizedlist>
        </xsl:with-param>
      </xsl:call-template>

      <!-- About main page -->
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="$xpref:name-about-page"/>
        <xsl:with-param name="title" select="'About XProcRef'"/>
        <xsl:with-param name="content">
          <db:para>TBD</db:para>
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

    <xsl:comment> == PAGES VERSION {$version-name} == </xsl:comment>

    <!-- Home page for version: -->
    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="local:href-result-file($version-id, $xpref:name-version-home-page)"/>
      <xsl:with-param name="title" select="'All steps for XProc version ' || $version-name"/>
      <xsl:with-param name="content">
        <xsl:call-template name="process-text">
          <xsl:with-param name="surrounding-elm" select="$version-elm/xpref:description"/>
        </xsl:call-template>
        <db:para>You can also view these steps <db:link xlink:href="{$xpref:name-categories-overview-page}">by category</db:link>.</db:para>
        <!-- List all the steps for this version: -->
        <xsl:call-template name="create-stepref-links">
          <xsl:with-param name="steprefs" select="$versionref-elm/xpref:stepref"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>

    <!-- Categories overview page for version: -->
    <!-- TBD -->
    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="local:href-result-file($version-id, $xpref:name-categories-overview-page)"/>
      <xsl:with-param name="title" select="'CATEGORIES VERSION ' || $version-name"/>
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
    </xsl:call-template>

    <!-- Page per category for this version: -->
    <xsl:for-each select="$versionref-elm/xpref:categoryref">
      <xsl:variable name="categoryref-elm" as="element(xpref:categoryref)" select="."/>
      <xsl:variable name="category-id" as="xs:string" select="xs:string($categoryref-elm/@id)"/>
      <xsl:variable name="category-elm" as="element(xpref:category)" select="$category-id-to-elm($category-id)"/>
      <xsl:variable name="category-name" as="xs:string" select="normalize-space($category-elm/@name)"/>
      <xsl:call-template name="create-docbook-article">
        <xsl:with-param name="href-target" select="local:href-result-file($version-id, local:category-page-name($category-id))"/>
        <xsl:with-param name="title" select="'Category: ' || $category-name"/>
        <xsl:with-param name="prev-next" select="local:get-prev-next($categoryref-elm)"/>
        <xsl:with-param name="content">
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="$category-elm/xpref:description"/>
          </xsl:call-template>
          <xsl:call-template name="create-stepref-links">
            <xsl:with-param name="steprefs" select="$categoryref-elm/xpref:stepref"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

    <!-- All steps for version: -->
    <xsl:apply-templates select="$versionref-elm/xpref:stepref">
      <xsl:with-param name="version-id" as="xs:string" select="$version-id" tunnel="true"/>
    </xsl:apply-templates>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xpref:stepref">
    <xsl:param name="version-id" as="xs:string" required="true" tunnel="true"/>

    <xsl:variable name="stepref-elm" as="element(xpref:stepref)" select="."/>
    <xsl:variable name="step-id" as="xs:string" select="xs:string($stepref-elm/@id)"/>
    <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
    <xsl:variable name="step-full-name" as="xs:string" select="local:step-full-name($step-id)"/>

    <xsl:call-template name="create-docbook-article">
      <xsl:with-param name="href-target" select="local:href-result-file($version-id, local:step-page-name($step-id))"/>
      <xsl:with-param name="prev-next" select="local:get-prev-next($stepref-elm)"/>
      <xsl:with-param name="title" select="'Step: ' || $step-full-name"/>
      <xsl:with-param name="content">
        <!-- The short description to start with: -->
        <db:para>{$step-elm/@short-description}</db:para>
        <!-- The signature: -->
        <xsl:call-template name="create-step-signature">
          <xsl:with-param name="step-id" select="$step-id"/>
        </xsl:call-template>

        <!-- Then the summary: -->
        <xsl:call-template name="process-text">
          <xsl:with-param name="surrounding-elm" select="$step-elm/xpref:summary"/>
        </xsl:call-template>
        <!-- Port and option tables: -->

        <!-- The port/option tables: -->
        <xsl:call-template name="create-step-tables">
          <xsl:with-param name="signature-elm" select="$step-elm/xpref:signature"/>
        </xsl:call-template>

        <!-- The description: -->
        <db:sect2>
          <db:title>Description</db:title>
          <xsl:call-template name="process-text">
            <xsl:with-param name="surrounding-elm" select="$step-elm/xpref:description"/>
          </xsl:call-template>
        </db:sect2>

        <!-- Any examples: -->
        <xsl:for-each select="$step-elm/xpref:example">
          <db:sect2>
            <db:title>Example: {@title}</db:title>
            <xsl:call-template name="process-text">
              <xsl:with-param name="surrounding-elm" select="."/>
            </xsl:call-template>
          </db:sect2>
        </xsl:for-each>

        <!-- Reference information: -->
        <db:sect2>
          <db:title>Reference information</db:title>

          <db:para>This description of the <db:code role="step">{$step-full-name}</db:code> step is for XProc version: <db:link
              xlink:href="{xpref:href-combine((), $xpref:name-version-home-page)}">{$version-id-to-elm($version-id)/@name}</db:link>.</db:para>

          <db:para>The formal specification for the <db:code role="step">{$step-full-name}</db:code> step can be found <db:link
              xlink:href="{$step-elm/xpref:specification-link/@href}" role="newpage">here</db:link>.</db:para>

          <xsl:variable name="category-refs" as="element(xpref:categoryref)*" select="$stepref-elm/xpref:categoryref"/>
          <xsl:choose>
            <xsl:when test="count($category-refs) eq 1">
              <xsl:variable name="category-id" as="xs:string" select="xs:string($category-refs[1]/@id)"/>
              <db:para>The <db:code role="step">{$step-full-name}</db:code> step is part of category: <db:link
                  xlink:href="{local:category-page-name($category-id)}">{$category-id-to-elm($category-id)/@name}</db:link>.</db:para>
            </xsl:when>
            <xsl:when test="count($category-refs) gt 1">
              <db:para>The <db:code role="step">{$step-full-name}</db:code> step is part of categories:</db:para>
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
            <db:para>The <db:code role="step">{$step-full-name}</db:code> step is also present in version{if (count($other-versionrefs) eq 1) then ()
              else 's'}: <xsl:for-each select="$other-versionrefs">
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
        <xsl:sequence select="local:declare-step-sub-element-to-string(., (@port, @primary))"/>
      </xsl:for-each>
      <!-- Non-primary ports: -->
      <xsl:for-each select="($signature-elm/(xpref:input | xpref:output))[not(xs:boolean(@primary))]">
        <xsl:sort select="local-name(.)"/>
        <xsl:sort select="xs:string(@port)"/>
        <xsl:sequence select="local:declare-step-sub-element-to-string(., (@port, @primary))"/>
      </xsl:for-each>
      <!-- Options: -->
      <xsl:for-each select="$signature-elm/xpref:option">
        <xsl:sort select="xs:string(@name)"/>
        <xsl:sequence select="local:declare-step-sub-element-to-string(., (@name, @as, @required, @select), (@subtype))"/>
      </xsl:for-each>
      <xsl:sequence select="'&lt;/p:declare-step&gt;'"/>
    </xsl:variable>

    <db:programlisting role="step-signature">
      <xsl:value-of select="string-join($lines, '&#10;')"/>
    </db:programlisting>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:declare-step-sub-element-to-string" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="attributes" as="attribute()*">
      <!-- Attributes in order of appearance. All other attributes are alphabetically sorted after these.-->
    </xsl:param>
    <xsl:param name="ignore-attributes" as="attribute()*"/>

    <xsl:variable name="parts" as="xs:string+">
      <xsl:sequence select="'  &lt;' || local-name($elm)"/>
      <xsl:for-each select="$attributes">
        <xsl:sequence select="' ' || xtlc:att2str(.)"/>
      </xsl:for-each>
      <xsl:for-each select="$elm/@* except ($attributes, $ignore-attributes)">
        <xsl:sort select="local-name(.)"/>
        <xsl:sequence select="' ' || xtlc:att2str(.)"/>
      </xsl:for-each>
      <xsl:sequence select="'/&gt;'"/>
    </xsl:variable>
    <xsl:sequence select="string-join($parts)"/>
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
              <db:para>Port name</db:para>
            </db:entry>
            <db:entry>
              <db:para>Primary</db:para>
            </db:entry>
            <db:entry>
              <db:para>Content types</db:para>
            </db:entry>
            <db:entry>
              <db:para>Sequence</db:para>
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

    <!-- Options: -->
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
              <db:para>As</db:para>
            </db:entry>
            <db:entry>
              <db:para>Required</db:para>
            </db:entry>
            <db:entry>
              <db:para>Select</db:para>
            </db:entry>
            <db:entry>
              <db:para>Description</db:para>
            </db:entry>
          </db:row>
        </db:thead>
        <db:tbody>

          <xsl:for-each select="$signature-elm/xpref:option">
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
                    <db:code>
                      <xsl:value-of select="@subtype"/>
                    </db:code>
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
              <db:entry>
                <db:para>
                  <db:code>
                    <xsl:value-of select="(@select, '&#160;')[1]"/>
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

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-port-table-row">
    <xsl:param name="port-elm" as="element()" required="false" select="."/>

    <db:row>
      <db:entry>
        <db:para>
          <xsl:value-of select="local-name($port-elm) => xtlc:capitalize()"/>
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
      <db:article version="5.0">
        <db:info>
          <db:title/>
        </db:info>
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

    <xsl:variable name="step-anchor-prefix" as="xs:string" select="'steps_'"/>

    <!-- Create a map with the referenced steps sorted on first character, in a map(first-character, sequence of step-ids) -->
    <xsl:variable name="grouped-referenced-steps" as="map(xs:string, xs:string)">
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
            </xsl:call-template>
          </db:sect2>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="create-steps-list">
          <xsl:with-param name="step-ids" select="for $stepref in $steprefs return xs:string($stepref/@id)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-steps-list">
    <xsl:param name="step-ids" as="xs:string*" required="true"/>

    <db:itemizedlist role="step-list">
      <xsl:for-each select="$step-ids">
        <xsl:variable name="step-id" as="xs:string" select="."/>
        <xsl:variable name="step-elm" as="element(xpref:step)" select="$step-id-to-elm($step-id)"/>
        <xsl:variable name="step-short-description" as="xs:string" select="normalize-space($step-elm/@short-description)"/>
        <db:listitem>
          <db:para><db:link xlink:href="{local:step-page-name($step-id)}">{local:step-full-name($step-id)}</db:link> -
            {$step-short-description}</db:para>
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

  <xsl:template match="*" mode="mode-process-text-inner-elements">
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

</xsl:stylesheet>
