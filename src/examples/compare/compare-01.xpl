<?xml version="1.0" encoding="UTF-8"?> 
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" sequence="true">
    <p:inline>
      <texts>
        <text>Hi there!</text>
      </texts>
    </p:inline>
    <p:inline>
      <texts>
        <text>Hi there!</text>
      </texts>
    </p:inline>
  </p:input>
  <p:output port="result" sequence="true"/>

  <p:compare name="c">
    <p:with-input port="alternate">
      <texts>
        <text>Hi there!</text>
      </texts>
    </p:with-input>
  </p:compare>

</p:declare-step>
