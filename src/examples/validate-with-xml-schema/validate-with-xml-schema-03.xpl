<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" href="input-invalid.xml"/>
  <p:output port="result" pipe="report@validate"/>

  <p:validate-with-xml-schema assert-valid="false" name="validate">
    <p:with-input port="schema" href="example.xsd"/>
  </p:validate-with-xml-schema>

</p:declare-step>
