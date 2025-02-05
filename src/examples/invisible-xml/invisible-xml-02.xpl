<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" href="grammar.txt"/>
  <p:output port="result"/>

  <p:invisible-xml>
    <p:with-input port="grammar">
      <p:empty/>
    </p:with-input>
  </p:invisible-xml>

</p:declare-step>
