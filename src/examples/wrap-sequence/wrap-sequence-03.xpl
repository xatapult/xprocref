<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" sequence="true">
    <fruits>
      <fruit name="banana" color="yellow"/>
      <fruit name="orange" color="orange"/>
      <fruit name="carrot" color="orange"/>
      <fruit name="lemon" color="yellow"/>
    </fruits>
  </p:input>
  <p:output port="result"/>

  <p:for-each>
    <p:with-input select="/*/*[@color eq 'yellow']"/>
    <p:add-attribute attribute-name="delivery" attribute-value="special"/>
  </p:for-each>

  <p:wrap-sequence wrapper="yellow-fruits"/>

</p:declare-step>
