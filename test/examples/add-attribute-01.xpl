<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source">
    <p:document href="in.xml"/>
  </p:input>
  <p:output port="result"/>

  <p:add-attribute match="text" attribute-name="type" attribute-value="special"/>

</p:declare-step>
