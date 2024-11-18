<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" sequence="true">
    <doc1/>
    <doc2/>
  </p:input>
  <p:output port="result" sequence="true"/>

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl/add-comment.xsl"></p:with-input>
  </p:xslt>
  
  <p:for-each>
    <p:identity message="** {base-uri(/)}"></p:identity>
  </p:for-each>

</p:declare-step>
