<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source">
    <thing>
      <uuid>UUID</uuid>
      <uuid>UUID</uuid>
    </thing>
  </p:input>
  <p:output port="result"/>

  <p:uuid match="/thing/uuid/text()"/>

</p:declare-step>