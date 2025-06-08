# XProcRef - Internal Documentation


* [Introduction](#section-d16e8)
* [Technical overview](#section-d16e42)
* [The XProcRef markup language](#section-d16e223)

  * [Overall structure](#section-d16e230)
  * [Describing a step](#section-d16e244)
  * [XprocRef DocBook sections](#section-d16e262)

    * [XprocRef specific DocBook extensions](#xprocref-docbook-extensions)

      * [Adding an XProc example with auto-execute ](#section-d16e495)





 

-----

## Introduction<a name="section-d16e8"/>


<image src="../resources/web/images/logo.png" width="20%"/>

XprocRef is an initiative to publish a website with descriptions for the XProc (3.0 and later) steps in a more user-friendly way than in the
      official specification. It is an initiative of Erik Siegel ([Xatapult Content Engineering](https://www.xatapult.nl)).

There is an underlying reason for this. In 2020 I published a book called “XProc 3.0 - Programmer Reference” (for sale [here](https://xmlpress.net/publications/xproc-3-0/)):


<image src="../resources/web/images/bookcover.png" width="15%"/>

Appendices A and B in the book describe the step library. However, due to time constraints, the step descriptions were copied from the
      formal XProc specification. This leaves much to be desired for users of the language: the specification is aimed at XProc processor
        *implementers*, not at language *users*. To correct this, this site contains reference information about
      the XProc steps, written from a more user-oriented perspective. With the increasing popularity of XProc, I hope this fills a need.

-----

## Technical overview<a name="section-d16e42"/>

***The website***


* XProcRef ([https://xprocref.org](https://xprocref.org)) is a static website containing descriptions of XProc steps. It is hosted as a GitHub Pages site from its GitHub repository [https://github.com/xatapult/xprocref](https://github.com/xatapult/xprocref).
* It uses Bootstrap 5.2.2
* All static website resources (CSS, JavaScript, etc.) can be found underneath `xprocref/web-resources/`. This all is copied verbatim to the final website.
* The template used to produce the actual web pages is: `xprocref/web-templates/default-template.html`.

***The markup language***


* All is generated from an XML source: `xprocref/src/xprocref.src.main.xml`
* This source uses an XProcRef specific markup language that is, more or less, described in this document.

  * A W3C XML Schema for the markup language is in: `xprocref/xsd/xprocref.xsd`
  * A Schematron Schema for the markup language with additional validations is in: `xprocref/sch/xprocref.sch`

* For the content/text parts of the markup, DocBook 5 is used. XprocRef adds several extension elements to provide for things like step cross-references, special markup, etc.

***Processing the markup into the website and PDF***


* Everything is based on XProc 3.0 pipelines (using XSLT 3.0 under the hood).<br/>**Note:** **Note:** The pipelines are currently (2025-06-08) processed by the MorganaXproc-III EE (Enterprise Edition) processor. The SE (Standard Edition) processor will not do the job because some steps are used that are available in the EE version only.
* The pipelines to run are in the `xprocref/xpl3/` directory. Their names should be reasonably self-explaining. If not, read the header documentation.
* Underlying pipelines are in `xprocref/xpl3mod/`. The main one is `xprocref/xpl3mod/process-xprocref-to-website.xpl` that takes care of everything.
* Processing makes heavy use of the facilities provided some other open source components published by [Xatapult](https://www.xatapult.nl):

  *  [Xtpxlib Common](https://common.xtpxlib.org/) 
  *  [Xtpxlib Container](https://container.xtpxlib.org/) 
  *  [Xtpxlib Xdoc](https://xdoc.xtpxlib.org/) 


-----

## The XProcRef markup language<a name="section-d16e223"/>

### Overall structure<a name="section-d16e230"/>

This is not documented (yet). Please refer to the schema in `xprocref/xsd/xprocref.xsd`.

### Describing a step<a name="section-d16e244"/>

This is not documented (yet). Please refer to the schema (`<step>` element) in `xprocref/xsd/xprocref.xsd`.

### XprocRef DocBook sections<a name="section-d16e262"/>

**Warning:** DocBook sections are *not* validated (yet)! 

For any element in the XprocRef markup that can contain text, the following applies:


* The basic language is DocBook 5 (the [xtpxlib-xdoc dialect](https://xdoc.xtpxlib.org/6_DocBook_dialect.html)), with [xtpxlib-xdoc](https://xdoc.xtpxlib.org/) extensions. These extensions can be used to, for instance, create descriptions of XML elements.
* Elements do *not* have to be in the DocBook namespace. Any element that is not in the DocBook 5 (`http://docbook.org/ns/docbook`) or xtpxlib-xdoc (`http://www.xtpxlib.nl/ns/xdoc`) namespace is automatically changed into the DOcBook namespace. 
* Any non-empty text element that is a direct child of the encompassing element is supposed to be in simple Markdown (see [here](https://xdoc.xtpxlib.org/5_XProc_3.0_support.html#xpl3-xtpxlib-xdoc.mod.xpl)) and transformed into DocBook automatically. 
* There are several additional elements that can be used on top of the normal DocBook and xtpxlib-xdoc elements. See [XprocRef specific DocBook extensions](#xprocref-docbook-extensions).

#### XprocRef specific DocBook extensions<a name="xprocref-docbook-extensions"/>


| Element | Description | 
| ----- | ----- | 
|  `<step>` <br/> `<port>` <br/> `<option>` <br/> `<property>`  | Adds some special markup for the name of the step, port, option or (document) property (an HTML class with the same value). <br/>An empty `<step>` element in a step description results in the step name itself. | 
|  `<step-error-ref code="…">`  | Adds a reference to one of the step errors. The text of the reference is the error *code*. | 
|  `<step-ref name="…" version-id?=…">`  | Adds a reference to a step. The name of the step must be including the namespace prefix (e.g. `name="p:identity"`).<br/>You can optionally refer to a step in another version by adding the `version-id` attribute. | 
|  `<category-ref idref="…">`  | Adds a reference to a category. The text of the reference is the name of the category. | 
|  `<example-ref idref=…" step-name?=…">`  | Adds a reference to an example. The text of the reference is the name of the example. | 
|  `<example-doc href="…">`  | Inserts some example document. This is done as (unparsed) text, so make sure XML documents have no XML header! | 

##### Adding an XProc example with auto-execute <a name="section-d16e495"/>


* It is possible to add XProc example pipelines that execute automatically. The result of this execution is available and shown as the result of the example pipeline.
* The XProc example pipeline must be self-running. That is, the input document must either be referenced (`@href`) on the `source` port or must be inlined. It will be presented for the example as a *separate* document. The reference or inlined document is removed from the pipeline in the example text.

