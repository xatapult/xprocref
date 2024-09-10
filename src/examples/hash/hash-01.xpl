<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source">
    <hash-value value=""/>
  </p:input>
  <p:output port="result" sequence="true" />

  <p:hash algorithm="sha" value="Hi there!" match="/"/>
  
</p:declare-step>
