<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" sequence="true">
    <doc1/>
    <doc2/>
  </p:input>
  <p:output port="result" sequence="true"/>

  <p:xslt name="t">
    <p:with-input port="stylesheet" href="xsl/add-comment.xsl"/>
  </p:xslt>

  <p:for-each>
    <p:identity message="** {base-uri(/)}"/>
  </p:for-each>

  <p:for-each>
    <p:with-input pipe="secondary@t"/>
    <p:identity message="**SECOND** {base-uri(/)}"/>
  </p:for-each>

</p:declare-step>
