<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:inline>
      <texts>
        <text>Hello there!</text>
        <text>This is funny…</text>
        <text type="normal">And that's normal.</text>
      </texts>
    </p:inline>
  </p:input>
  <p:output port="result" primary="true" sequence="false" content-types="xml"/>

  <p:add-attribute match="text" attribute-name="type" attribute-value="special"/>

</p:declare-step>
