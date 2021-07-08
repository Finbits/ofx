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
                 status_severity: :info,
                 export_date: %DateTime{
                   year: 2021,
                   month: 2,
                   day: 18,
                   hour: 10,
                   minute: 00,
                   second: 00,
                   time_zone: "EST",
                   zone_abbr: "EST",
                   utc_offset: -10_800,
                   std_offset: 0
                 }
               },
               bank: [
                 %{
                   account_id: "9352226196",
                   account_type: "checking",
                   balance: %{
                     amount: 6151.76,
                     date: %DateTime{
                       year: 2021,
                       month: 2,
                       day: 18,
                       hour: 10,
                       minute: 0,
                       second: 0,
                       time_zone: "EST",
                       zone_abbr: "EST",
                       utc_offset: -10_800,
                       std_offset: 0
                     },
                     int_positive_amount: 615_176,
                     amount_type: :credit
                   },
                   currency: "BRL",
                   description: "",
                   request_id: "1001",
                   routing_number: "0341",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: %DateTime{
                       year: 2021,
                       month: 2,
                       day: 26,
                       hour: 10,
                       minute: 0,
                       second: 0,
                       time_zone: "EST",
                       zone_abbr: "EST",
                       utc_offset: -10_800,
                       std_offset: 0
                     },
                     list: [
                       %{
                         amount: -44.99,
                         check_number: "20210126002",
                         currency: "BRL",
                         fit_id: "20210126002",
                         int_positive_amount: 4499,
                         memo: "DA  VIVO-SP 04077306573",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 1,
                           day: 26,
                           hour: 10,
                           minute: 0,
                           second: 0,
                           time_zone: "EST",
                           zone_abbr: "EST",
                           utc_offset: -10_800,
                           std_offset: 0
                         },
                         amount_type: :debit,
                         type: "debit"
                       }
                     ],
                     start_date: %DateTime{
                       year: 2021,
                       month: 1,
                       day: 21,
                       hour: 10,
                       minute: 0,
                       second: 0,
                       time_zone: "EST",
                       zone_abbr: "EST",
                       utc_offset: -10_800,
                       std_offset: 0
                     }
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
                     date: %DateTime{
                       year: 2017,
                       month: 1,
                       day: 27,
                       hour: 12,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
                     int_positive_amount: 100_000_100
                   },
                   currency: "USD",
                   description: "",
                   request_id: "0",
                   routing_number: "019283745",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: %DateTime{
                       year: 2017,
                       month: 1,
                       day: 27,
                       hour: 12,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
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
                         posted_date: %DateTime{
                           year: 2017,
                           month: 1,
                           day: 23,
                           hour: 12,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
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
                         posted_date: %DateTime{
                           year: 2017,
                           month: 1,
                           day: 20,
                           hour: 12,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
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
                         posted_date: %DateTime{
                           year: 2017,
                           month: 1,
                           day: 13,
                           hour: 12,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "check"
                       }
                     ],
                     start_date: %DateTime{
                       year: 1970,
                       month: 1,
                       day: 1,
                       hour: 12,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     }
                   }
                 },
                 %{
                   account_id: "0000000007539546821",
                   account_type: "checking",
                   balance: %{
                     amount: 85_263.0,
                     amount_type: :credit,
                     date: %DateTime{
                       year: 2017,
                       month: 1,
                       day: 27,
                       hour: 12,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
                     int_positive_amount: 8_526_300
                   },
                   currency: "USD",
                   description: "",
                   request_id: "0",
                   routing_number: "019283745",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: %DateTime{
                       year: 2017,
                       month: 1,
                       day: 27,
                       hour: 12,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
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
                         posted_date: %DateTime{
                           year: 2017,
                           month: 1,
                           day: 23,
                           hour: 12,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "debit"
                       }
                     ],
                     start_date: %DateTime{
                       year: 1970,
                       month: 1,
                       day: 1,
                       hour: 12,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     }
                   }
                 }
               ],
               signon: %{
                 financial_institution: "Whip & Whirl",
                 language: "ENG",
                 status_code: 0,
                 status_message: "",
                 status_severity: :info,
                 export_date: %DateTime{
                   year: 2017,
                   month: 1,
                   day: 27,
                   hour: 11,
                   minute: 1,
                   second: 31,
                   time_zone: "EST",
                   zone_abbr: "EST",
                   utc_offset: -18_000,
                   std_offset: 0
                 }
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
               status_severity: :info,
               export_date: %DateTime{
                 year: 2017,
                 month: 1,
                 day: 27,
                 hour: 11,
                 minute: 1,
                 second: 31,
                 time_zone: "EST",
                 zone_abbr: "EST",
                 utc_offset: -18_000,
                 std_offset: 0
               }
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
                    status_severity: :error,
                    export_date: %DateTime{
                      year: 2018,
                      month: 10,
                      day: 07,
                      hour: 22,
                      minute: 25,
                      second: 26,
                      time_zone: "UTC",
                      zone_abbr: "UTC",
                      utc_offset: -14_400,
                      std_offset: 0
                    }
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

      assert result == {:error, %{data: "", message: "Amount is invalid or was not found"}}
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
                 status_severity: :info,
                 export_date: %DateTime{
                   year: 2021,
                   month: 02,
                   day: 18,
                   hour: 10,
                   minute: 0,
                   second: 0,
                   time_zone: "EST",
                   zone_abbr: "EST",
                   utc_offset: -10_800,
                   std_offset: 0
                 }
               },
               bank: [
                 %{
                   account_id: "9352226196",
                   account_type: "checking",
                   balance: %{
                     amount: 6151.76,
                     date: %DateTime{
                       year: 2021,
                       month: 02,
                       day: 18,
                       hour: 10,
                       minute: 0,
                       second: 0,
                       time_zone: "EST",
                       zone_abbr: "EST",
                       utc_offset: -10_800,
                       std_offset: 0
                     },
                     int_positive_amount: 615_176,
                     amount_type: :credit
                   },
                   currency: "BRL",
                   description: "",
                   request_id: "1001",
                   routing_number: "0341",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: %DateTime{
                       year: 2021,
                       month: 02,
                       day: 26,
                       hour: 10,
                       minute: 0,
                       second: 0,
                       time_zone: "EST",
                       zone_abbr: "EST",
                       utc_offset: -10_800,
                       std_offset: 0
                     },
                     list: [
                       %{
                         amount: -44.99,
                         check_number: "20210126002",
                         currency: "BRL",
                         fit_id: "20210126002",
                         int_positive_amount: 4499,
                         memo: "DA  VIVO-SP 04077306573",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 01,
                           day: 26,
                           hour: 10,
                           minute: 0,
                           second: 0,
                           time_zone: "EST",
                           zone_abbr: "EST",
                           utc_offset: -10_800,
                           std_offset: 0
                         },
                         amount_type: :debit,
                         type: "debit"
                       }
                     ],
                     start_date: %DateTime{
                       year: 2021,
                       month: 1,
                       day: 21,
                       hour: 10,
                       minute: 0,
                       second: 0,
                       time_zone: "EST",
                       zone_abbr: "EST",
                       utc_offset: -10_800,
                       std_offset: 0
                     }
                   }
                 }
               ]
             }
    end

    test "parse latin1 encoded files" do
      ofx_raw = File.read!("test/support/fixtures/latin_encoding.ofx")

      assert {:ok, result} = Parser.parse(ofx_raw)

      assert result == %{
               bank: [
                 %{
                   account_id: "1198276",
                   account_type: "checking",
                   balance: %{
                     amount: 1.0,
                     amount_type: :credit,
                     date: %DateTime{
                       year: 2021,
                       month: 6,
                       day: 29,
                       hour: 0,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
                     int_positive_amount: 100
                   },
                   currency: "BRL",
                   description: "",
                   request_id: "1001",
                   routing_number: "077",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: %DateTime{
                       year: 2021,
                       month: 6,
                       day: 29,
                       hour: 0,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
                     list: [
                       %{
                         amount: 159.9,
                         amount_type: :credit,
                         check_number: "077",
                         currency: "BRL",
                         fit_id: "12/04/2021077",
                         int_positive_amount: 15990,
                         memo: "PAGAMENTO CASHBACK 9832-01",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 4,
                           day: 12,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "credit"
                       },
                       %{
                         amount: -159.9,
                         amount_type: :debit,
                         check_number: "077",
                         currency: "BRL",
                         fit_id: "05/05/2021077",
                         int_positive_amount: 15990,
                         memo: "PAGAMENTO FATURA INTER - Pagamento Fatura Cartão Inter",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 5,
                           day: 5,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "electronic_payment"
                       },
                       %{
                         amount: 0.39,
                         amount_type: :credit,
                         check_number: "077",
                         currency: "BRL",
                         fit_id: "06/05/2021077",
                         int_positive_amount: 39,
                         memo: "CASHBACK CARTAO DE CREDITO -",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 5,
                           day: 6,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "credit"
                       },
                       %{
                         amount: 220.0,
                         amount_type: :credit,
                         check_number: "077",
                         currency: "BRL",
                         fit_id: "07/06/2021077",
                         int_positive_amount: 22000,
                         memo: "PIX RECEBIDO - Cp :98127- Jonny",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 7,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "credit"
                       },
                       %{
                         amount: -219.9,
                         amount_type: :debit,
                         check_number: "077",
                         currency: "BRL",
                         fit_id: "07/06/2021077",
                         int_positive_amount: 21990,
                         memo: "PAGAMENTO FATURA INTER - Débito Automático Fatura Cartão Inter",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 7,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "electronic_payment"
                       },
                       %{
                         amount: 0.54,
                         amount_type: :credit,
                         check_number: "077",
                         currency: "BRL",
                         fit_id: "09/06/2021077",
                         int_positive_amount: 54,
                         memo: "CASHBACK CARTAO DE CREDITO -",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 9,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "credit"
                       }
                     ],
                     start_date: %DateTime{
                       year: 2021,
                       month: 3,
                       day: 31,
                       hour: 0,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     }
                   }
                 }
               ],
               signon: %{
                 financial_institution: "Banco Inter S/A",
                 language: "POR",
                 status_code: 0,
                 status_message: "",
                 status_severity: :info,
                 export_date: %DateTime{
                   year: 2021,
                   month: 6,
                   day: 29,
                   hour: 0,
                   minute: 0,
                   second: 0,
                   time_zone: "UTC",
                   zone_abbr: "UTC",
                   utc_offset: 0,
                   std_offset: 0
                 }
               }
             }
    end

    test "parse UTF-8 encoded files" do
      ofx_raw = File.read!("test/support/fixtures/utf8_encoding.ofx")

      assert {:ok, result} = Parser.parse(ofx_raw)

      assert result == %{
               bank: [
                 %{
                   account_id: "1234567",
                   account_type: "checking",
                   balance: %{
                     amount: 1.0,
                     amount_type: :credit,
                     date: nil,
                     int_positive_amount: 100
                   },
                   currency: "",
                   description: "",
                   request_id: "1001",
                   routing_number: "218",
                   status: %{code: 0, severity: :info},
                   transactions: %{
                     end_date: %DateTime{
                       year: 2021,
                       month: 6,
                       day: 30,
                       hour: 0,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     },
                     list: [
                       %{
                         amount: 1.0,
                         amount_type: :credit,
                         check_number: "0",
                         currency: "",
                         fit_id: "b4b21a25-38e5-40b6-9b40-b5a92b8df1e2",
                         int_positive_amount: 100,
                         memo: "Crédito Pix Manual",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 30,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "credit"
                       },
                       %{
                         amount: -0.5,
                         amount_type: :debit,
                         check_number: "0",
                         currency: "",
                         fit_id: "1b08f8b7-6052-4802-ad69-b4db2480c19d",
                         int_positive_amount: 50,
                         memo: "Tarifa Operações Pix",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 30,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "debit"
                       },
                       %{
                         amount: -0.5,
                         amount_type: :debit,
                         check_number: "0",
                         currency: "",
                         fit_id: "28586af6-6546-4e28-a7b5-f887f2131559",
                         int_positive_amount: 50,
                         memo: "Débito Pix",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 30,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "debit"
                       },
                       %{
                         amount: 1.0,
                         amount_type: :credit,
                         check_number: "0",
                         currency: "",
                         fit_id: "c8be57a0-f757-4d91-b1c2-82127c5503ae",
                         int_positive_amount: 100,
                         memo: "Crédito Pix Chave",
                         name: "",
                         posted_date: %DateTime{
                           year: 2021,
                           month: 6,
                           day: 30,
                           hour: 0,
                           minute: 0,
                           second: 0,
                           time_zone: "UTC",
                           zone_abbr: "UTC",
                           utc_offset: 0,
                           std_offset: 0
                         },
                         type: "credit"
                       }
                     ],
                     start_date: %DateTime{
                       year: 2021,
                       month: 6,
                       day: 30,
                       hour: 0,
                       minute: 0,
                       second: 0,
                       time_zone: "UTC",
                       zone_abbr: "UTC",
                       utc_offset: 0,
                       std_offset: 0
                     }
                   }
                 }
               ],
               signon: %{
                 export_date: %DateTime{
                   year: 2021,
                   month: 7,
                   day: 1,
                   hour: 0,
                   minute: 0,
                   second: 0,
                   time_zone: "UTC",
                   zone_abbr: "UTC",
                   utc_offset: 0,
                   std_offset: 0
                 },
                 financial_institution: "Banco BS2 S.A.",
                 language: "POR",
                 status_code: 0,
                 status_message: "",
                 status_severity: :info
               }
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

      assert_raise Error, "Amount is invalid or was not found", fn ->
        Parser.parse!(ofx_data)
      end
    end
  end
end
