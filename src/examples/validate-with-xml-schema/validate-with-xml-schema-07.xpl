<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" href="input-valid-bound.xml"/>
  <p:output port="result"/>

  <p:validate-with-xml-schema use-location-hints="true">
    <p:with-input port="schema">
      <p:empty/>
    </p:with-input>
  </p:validate-with-xml-schema>

</p:declare-step>
