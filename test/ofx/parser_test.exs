defmodule Ofx.ParserTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser
  alias Ofx.Parser.Error

  describe "parse/1" do
    test "parse a statement account ofx" do
      ofx_raw = File.read!("test/support/fixtures/sample.ofx")

      assert {:ok, result} = Parser.parse(ofx_raw)

      assert result == %{
               signon: %{
                 financial_institution: "",
                 language: "POR",
                 status_code: 0,
                 status_message: "",
                 status_severity: :info
               },
               bank: [
                 %{
                   account_id: "9352226196",
                   account_type: "checking",
                   balance: %{
                     amount: 6151.76,
                     date: ~N[2021-02-18 07:00:00],
                     int_positive_amount: 615_176,
                     amount_type: :credit
                   },
                   currency: "BRL",
                   description: "",
                   request_id: "1001",
                   routing_number: "0341",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: ~N[2021-02-26 07:00:00],
                     list: [
                       %{
                         amount: -44.99,
                         check_number: "20210126002",
                         currency: "BRL",
                         fit_id: "20210126002",
                         int_positive_amount: 4499,
                         memo: "DA  VIVO-SP 04077306573",
                         name: "",
                         posted_date: ~N[2021-01-26 07:00:00],
                         amount_type: :debit,
                         type: "debit"
                       }
                     ],
                     start_date: ~N[2021-01-21 07:00:00]
                   }
                 }
               ]
             }
    end

    test "ofx with multiple accounts" do
      ofx_raw = File.read!("test/support/fixtures/multiple_accounts.ofx")

      assert {:ok, result} = Parser.parse(ofx_raw)

      assert result == %{
               bank: [
                 %{
                   account_id: "00000000012345678910",
                   account_type: "checking",
                   balance: %{
                     amount: 1_000_001.0,
                     amount_type: :credit,
                     date: ~N[2017-01-27 12:00:00],
                     int_positive_amount: 100_000_100
                   },
                   currency: "USD",
                   description: "",
                   request_id: "0",
                   routing_number: "019283745",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: ~N[2017-01-27 12:00:00],
                     list: [
                       %{
                         amount: -7.0,
                         amount_type: :debit,
                         check_number: "",
                         currency: "USD",
                         fit_id: "4614806509201701231",
                         int_positive_amount: 700,
                         memo: "This is where a memo goes",
                         name: "This is where the name is",
                         posted_date: ~N[2017-01-23 12:00:00],
                         type: "debit"
                       },
                       %{
                         amount: 372.07,
                         amount_type: :credit,
                         check_number: "",
                         currency: "USD",
                         fit_id: "4614806509201701201",
                         int_positive_amount: 37_207,
                         memo: "#YOLO",
                         name: "BUYING ALL THE THINGS",
                         posted_date: ~N[2017-01-20 12:00:00],
                         type: "credit"
                       },
                       %{
                         amount: -40.0,
                         amount_type: :debit,
                         check_number: "275",
                         currency: "USD",
                         fit_id: "3113342346901135",
                         int_positive_amount: 4000,
                         memo: "",
                         name: "CHECK 275 342857403598",
                         posted_date: ~N[2017-01-13 12:00:00],
                         type: "check"
                       }
                     ],
                     start_date: ~N[1970-01-01 12:00:00]
                   }
                 },
                 %{
                   account_id: "0000000007539546821",
                   account_type: "checking",
                   balance: %{
                     amount: 85_263.0,
                     amount_type: :credit,
                     date: ~N[2017-01-27 12:00:00],
                     int_positive_amount: 8_526_300
                   },
                   currency: "USD",
                   description: "",
                   request_id: "0",
                   routing_number: "019283745",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: ~N[2017-01-27 12:00:00],
                     list: [
                       %{
                         amount: -7.0,
                         amount_type: :debit,
                         check_number: "",
                         currency: "USD",
                         fit_id: "4614806509201701231",
                         int_positive_amount: 700,
                         memo: "This is where a memo goes",
                         name: "This is where the name is",
                         posted_date: ~N[2017-01-23 12:00:00],
                         type: "debit"
                       }
                     ],
                     start_date: ~N[1970-01-01 12:00:00]
                   }
                 }
               ],
               signon: %{
                 financial_institution: "Whip & Whirl",
                 language: "ENG",
                 status_code: 0,
                 status_message: "",
                 status_severity: :info
               }
             }
    end

    test "parse a xml format ofx" do
      ofx_raw = File.read!("test/support/fixtures/xml_header_example.ofx")

      assert {:ok, %{signon: signon, bank: bank}} = Parser.parse(ofx_raw)

      assert is_list(bank)
      assert length(bank) == 2

      assert signon == %{
               financial_institution: "Galactic CU",
               language: "ENG",
               status_code: 0,
               status_message: "",
               status_severity: :info
             }
    end

    test "ofx with status error" do
      ofx_raw = File.read!("test/support/fixtures/status_error.ofx")

      result = Parser.parse(ofx_raw)

      assert result ==
               {:ok,
                %{
                  signon: %{
                    financial_institution: "",
                    language: "ENG",
                    status_code: 2000,
                    status_message:
                      "We were unable to process your request. Please try again later.",
                    status_severity: :error
                  }
                }}
    end

    test "error for broken ofx" do
      ofx_raw = File.read!("test/support/fixtures/broken.ofx")

      result = Parser.parse(ofx_raw)

      assert {:error,
              %{
                data: {text, {:col, 145}},
                message: "Missing tag end. Expected: OFX. Found: SIGNONMSGSRSV1."
              }} = result

      assert is_binary(text)
    end

    test "return error for invalid format" do
      ofx_data = """
      <OFX>
      <BANKMSGSRSV1>
      <STMTTRNRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>INFO</SEVERITY>
      </STATUS>
      <STMTRS>
      <CURDEF>BRL</CURDEF>
      <BANKACCTFROM>
      <ACCTTYPE>CHECKING</ACCTTYPE>
      </BANKACCTFROM>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      </OFX>
      """

      result = Parser.parse(ofx_data)

      assert result == {:error, %{data: "", message: "Date has invalid format or was not found"}}
    end
  end

  describe "parse!/1" do
    test "parse a statement account ofx" do
      ofx_raw = File.read!("test/support/fixtures/sample.ofx")

      result = Parser.parse!(ofx_raw)

      assert result == %{
               signon: %{
                 financial_institution: "",
                 language: "POR",
                 status_code: 0,
                 status_message: "",
                 status_severity: :info
               },
               bank: [
                 %{
                   account_id: "9352226196",
                   account_type: "checking",
                   balance: %{
                     amount: 6151.76,
                     date: ~N[2021-02-18 07:00:00],
                     int_positive_amount: 615_176,
                     amount_type: :credit
                   },
                   currency: "BRL",
                   description: "",
                   request_id: "1001",
                   routing_number: "0341",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: ~N[2021-02-26 07:00:00],
                     list: [
                       %{
                         amount: -44.99,
                         check_number: "20210126002",
                         currency: "BRL",
                         fit_id: "20210126002",
                         int_positive_amount: 4499,
                         memo: "DA  VIVO-SP 04077306573",
                         name: "",
                         posted_date: ~N[2021-01-26 07:00:00],
                         amount_type: :debit,
                         type: "debit"
                       }
                     ],
                     start_date: ~N[2021-01-21 07:00:00]
                   }
                 }
               ]
             }
    end

    test "raise exception for invalid format" do
      ofx_data = """
      <OFX>
      <BANKMSGSRSV1>
      <STMTTRNRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>INFO</SEVERITY>
      </STATUS>
      <STMTRS>
      <CURDEF>BRL</CURDEF>
      <BANKACCTFROM>
      <ACCTTYPE>CHECKING</ACCTTYPE>
      </BANKACCTFROM>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      </OFX>
      """

      assert_raise Error, "Date has invalid format or was not found", fn ->
        Parser.parse!(ofx_data)
      end
    end
  end
end
