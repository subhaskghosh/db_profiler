-- file:xml.sql ln:453 expect:true
INSERT INTO xmldata VALUES('<ROWS>
<ROW id="10">
  <COUNTRY_ID>CZ</COUNTRY_ID>
  <COUNTRY_NAME>Czech Republic</COUNTRY_NAME>
  <REGION_ID>2</REGION_ID><PREMIER_NAME>Milos Zeman</PREMIER_NAME>
</ROW>
<ROW id="11">
  <COUNTRY_ID>DE</COUNTRY_ID>
  <COUNTRY_NAME>Germany</COUNTRY_NAME>
  <REGION_ID>2</REGION_ID>
</ROW>
<ROW id="12">
  <COUNTRY_ID>FR</COUNTRY_ID>
  <COUNTRY_NAME>France</COUNTRY_NAME>
  <REGION_ID>2</REGION_ID>
</ROW>
</ROWS>')