defmodule Ofx.Parser.SignonTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.{Error, Signon}

  describe "format/1" do
    test "format signon message" do
      signon_example = """
      <SIGNONMSGSRSV1>
      <SONRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>INFO</SEVERITY>
      <MESSAGE>SUCCESS</MESSAGE>
      </STATUS>
      <DTSERVER>20210218100000[-03:EST]</DTSERVER>
      <LANGUAGE>POR</LANGUAGE>
      <FI>
      <ORG>International Bank</ORG>
      </FI>
      </SONRS>
      </SIGNONMSGSRSV1>
      """

      xml_data = SweetXml.parse(signon_example)

      result = Signon.format(xml_data)

      assert result == %{
               financial_institution: "International Bank",
               language: "POR",
               status_code: 0,
               status_severity: :info,
               status_message: "SUCCESS",
               export_date: %DateTime{
                 year: 2021,
                 month: 02,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "EST",
                 zone_abbr: "EST",
                 utc_offset: -10_800,
                 std_offset: 0
               }
             }
    end

    test "when signon has't message and financial info" do
      signon_example = """
      <SIGNONMSGSRSV1>
      <SONRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>INFO</SEVERITY>
      </STATUS>
      <DTSERVER>20210218100000[-03:EST]</DTSERVER>
      <LANGUAGE>POR</LANGUAGE>
      </SONRS>
      </SIGNONMSGSRSV1>
      """

      xml_data = SweetXml.parse(signon_example)

      result = Signon.format(xml_data)

      assert result == %{
               financial_institution: "",
               language: "POR",
               status_code: 0,
               status_severity: :info,
               status_message: "",
               export_date: %DateTime{
                 year: 2021,
                 month: 02,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "EST",
                 zone_abbr: "EST",
                 utc_offset: -10_800,
                 std_offset: 0
               }
             }
    end

    test "raise error for invalid status code" do
      signon_example = """
      <SIGNONMSGSRSV1>
      <SONRS>
      <STATUS>
      <CODE>invalid</CODE>
      <SEVERITY>INFO</SEVERITY>
      </STATUS>
      </SONRS>
      </SIGNONMSGSRSV1>
      """

      xml_data = SweetXml.parse(signon_example)

      assert_raise Error, "Invalid SIGNON message", fn ->
        Signon.format(xml_data)
      end
    end

    test "raise error for invalid status severity" do
      signon_example = """
      <SIGNONMSGSRSV1>
      <SONRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>invalid</SEVERITY>
      </STATUS>
      </SONRS>
      </SIGNONMSGSRSV1>
      """

      xml_data = SweetXml.parse(signon_example)

      assert_raise Error, "Severity is unknown", fn ->
        Signon.format(xml_data)
      end
    end

    test "return export_date as 'nil' when server date is invalid" do
      signon_example = """
      <SIGNONMSGSRSV1>
      <SONRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>INFO</SEVERITY>
      </STATUS>
      <DTSERVER>00000000000000</DTSERVER>
      <LANGUAGE>POR</LANGUAGE>
      </SONRS>
      </SIGNONMSGSRSV1>
      """

      xml_data = SweetXml.parse(signon_example)

      result = Signon.format(xml_data)

      assert result == %{
               export_date: nil,
               financial_institution: "",
               language: "POR",
               status_code: 0,
               status_message: "",
               status_severity: :info
             }
    end
  end

  describe "append_message/2" do
    test "create signon  key when map have not" do
      signon = %{
        financial_institution: "",
        language: "POR",
        status_code: 0,
        status_severity: :info,
        status_message: ""
      }

      result = Signon.append_message(signon, %{})

      assert result == %{signon: signon}
    end

    test "overwrite previus signon key" do
      signon = %{
        financial_institution: "",
        language: "POR",
        status_code: 0,
        status_severity: :info,
        status_message: ""
      }

      result = Signon.append_message(signon, %{signon: "somevalue"})

      assert result == %{signon: signon}
    end
  end
end
