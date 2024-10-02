<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0">

  <p:input port="source">
    <p:inline >
      <?xxx?>
      <things>
        <thing name="screw" id="A123"/>
        <thing name="screw" id="A123"/>
      </things>
    </p:inline>
  </p:input>
  <p:output port="result"/>

  <p:replace match="/">
    <p:with-input port="replacement">
      <p:inline content-type="text/html"><HTML/></p:inline>
      <!--<replaced-element/>-->
    </p:with-input>
  </p:replace>

  <p:identity message="*** {p:document-property(., 'content-type')}"/>

</p:declare-step>
