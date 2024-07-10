<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" href="test.zip"/>
  <p:output port="result"/>

  <p:archive-manifest>
    <p:with-option name="override-content-types" select="[ ['\.png$', 'application/octet-stream'] ]"/>
  </p:archive-manifest>

</p:declare-step>