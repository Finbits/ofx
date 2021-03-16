defmodule Ofx.Parser.UtilsTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.Utils

  describe "remove_special_chars/1" do
    test "safe remove &" do
      string = "<TAG>C&C</TAG>"

      result = Utils.remove_special_chars(string)

      assert result == "<TAG>C&amp;C</TAG>"
    end
  end

  describe "remove_white_spaces/1" do
    test "remove white spaces between tags" do
      string = """
      <TAG1> Value Tag </TAG1>  <TAG2> </TAG2>
          <TAG3>    
          </TAG3>
          <TAG3>    
           Value
          </TAG3>
      """

      result = Utils.remove_white_spaces(string)

      assert result == "<TAG1>Value Tag</TAG1><TAG2></TAG2><TAG3></TAG3><TAG3>Value</TAG3>"
    end
  end

  describe "remove_file_headers/1" do
    test "remove data headers and keep junst OFX tag content" do
      xml_headers = """
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>

      <?OFX OFXHEADER="200" VERSION="200" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>

      <OFX>
          <SIGNONMSGSRSV1>
          </SIGNONMSGSRSV1>
      </OFX>
      """

      sgml_headers = """
      OFXHEADER:100
      DATA:OFXSGML
      VERSION:102
      SECURITY:NONE
      ENCODING:USASCII
      CHARSET:1252
      COMPRESSION:NONE
      OLDFILEUID:NONE
      NEWFILEUID:NONE

      <OFX>
          <SIGNONMSGSRSV1>
          </SIGNONMSGSRSV1>
      </OFX>
      """

      expected_content = """
      <OFX>
          <SIGNONMSGSRSV1>
          </SIGNONMSGSRSV1>
      </OFX>
      """

      assert Utils.remove_file_headers(xml_headers) == expected_content
      assert Utils.remove_file_headers(sgml_headers) == expected_content
    end
  end

  describe "write_close_tags/1" do
    test "close open tags" do
      xml = "<TAG1>value here</TAG1><TAG2>other value<TAG3> tag3 value<TAG1> tag1"

      expected =
        "<TAG1>value here</TAG1><TAG2>other value</TAG2><TAG3> tag3 value</TAG3><TAG1> tag1</TAG1>"

      assert Utils.write_close_tags(xml) == expected
    end
  end
end
