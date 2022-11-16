defmodule Ofx.Parser.BankTest do
  use ExUnit.Case, async: true

  import SweetXml, only: [sigil_x: 2]

  alias Ofx.Parser.{Bank, Error}

  describe "format/1" do
    test "format bank message" do
      bank_example =
        "test/support/fixtures/bankmsgsrsv1.ofx"
        |> File.read!()
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//OFX/BANKMSGSRSV1")

      result = Bank.format(bank_example)

      assert result == [
               %{
                 request_id: "1001",
                 routing_number: "0341",
                 account_id: "9352226196",
                 description: "",
                 account_type: "checking",
                 currency: "BRL",
                 status: %{code: 0, severity: :info},
                 balance: %{
                   date: %DateTime{
                     year: 2021,
                     month: 2,
                     day: 18,
                     hour: 10,
                     minute: 0,
                     second: 0,
                     microsecond: {0, 3},
                     time_zone: "EST",
                     zone_abbr: "EST",
                     utc_offset: -10_800,
                     std_offset: 0
                   },
                   amount: 6151.76,
                   int_positive_amount: 615_176,
                   amount_type: :credit
                 },
                 transactions: %{
                   start_date: %DateTime{
                     year: 2021,
                     month: 1,
                     day: 21,
                     hour: 10,
                     minute: 0,
                     second: 0,
                     microsecond: {0, 3},
                     time_zone: "EST",
                     zone_abbr: "EST",
                     utc_offset: -10_800,
                     std_offset: 0
                   },
                   end_date: %DateTime{
                     year: 2021,
                     month: 2,
                     day: 26,
                     hour: 10,
                     minute: 0,
                     second: 0,
                     microsecond: {0, 3},
                     time_zone: "EST",
                     zone_abbr: "EST",
                     utc_offset: -10_800,
                     std_offset: 0
                   },
                   list: [
                     %{
                       posted_date: %DateTime{
                         year: 2021,
                         month: 1,
                         day: 21,
                         hour: 10,
                         minute: 0,
                         second: 0,
                         microsecond: {0, 3},
                         time_zone: "EST",
                         zone_abbr: "EST",
                         utc_offset: -10_800,
                         std_offset: 0
                       },
                       fit_id: "20210121001",
                       check_number: "20210121001",
                       ref_num: "",
                       name: "",
                       memo: "DA  COMGAS 39309134",
                       type: "debit",
                       amount: -34.34,
                       int_positive_amount: 3434,
                       amount_type: :debit,
                       currency: "BRL"
                     }
                   ]
                 }
               }
             ]
    end

    test "without transactions date" do
      bank_example =
        "test/support/fixtures/bankmsgsrsv1_with_out_transactions_date.ofx"
        |> File.read!()
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//OFX/BANKMSGSRSV1")

      result = Bank.format(bank_example)

      assert result == [
               %{
                 account_id: "00000000085245679130",
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
                     microsecond: {0, 3},
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
                   start_date: nil,
                   end_date: nil,
                   list: [
                     %{
                       amount: -40.0,
                       amount_type: :debit,
                       check_number: "275",
                       ref_num: "",
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
                         microsecond: {0, 3},
                         time_zone: "UTC",
                         zone_abbr: "UTC",
                         utc_offset: 0,
                         std_offset: 0
                       },
                       type: "check"
                     }
                   ]
                 }
               }
             ]
    end

    test "returns date as nil when there is not date on balance info" do
      bank_msg = """
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
      <LEDGERBAL>
      <BALAMT>0.00</BALAMT>
      </LEDGERBAL>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      """

      bank_example =
        bank_msg
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//BANKMSGSRSV1")

      result = Bank.format(bank_example)

      assert result == [
               %{
                 account_id: "",
                 account_type: "checking",
                 balance: %{
                   amount: 0.0,
                   amount_type: :credit,
                   date: nil,
                   int_positive_amount: 0
                 },
                 currency: "BRL",
                 description: "",
                 request_id: "",
                 routing_number: "",
                 status: %{
                   code: 0,
                   severity: :info
                 },
                 transactions: %{
                   end_date: nil,
                   list: [],
                   start_date: nil
                 }
               }
             ]
    end

    test "returns balance as nil when there is no balance info" do
      bank_msg = """
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
      """

      bank_example =
        bank_msg
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//BANKMSGSRSV1")

      result = Bank.format(bank_example)

      assert result == [
               %{
                 account_id: "",
                 account_type: "checking",
                 balance: nil,
                 currency: "BRL",
                 description: "",
                 request_id: "",
                 routing_number: "",
                 status: %{
                   code: 0,
                   severity: :info
                 },
                 transactions: %{
                   end_date: nil,
                   list: [],
                   start_date: nil
                 }
               }
             ]
    end

    test "returns status as nil when there is no status info" do
      bank_msg = """
      <BANKMSGSRSV1>
      <STMTTRNRS>
      <STMTRS>
      <CURDEF>BRL</CURDEF>
      <BANKACCTFROM>
      <ACCTTYPE>CHECKING</ACCTTYPE>
      </BANKACCTFROM>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      """

      bank_example =
        bank_msg
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//BANKMSGSRSV1")

      result = Bank.format(bank_example)

      assert result == [
               %{
                 account_id: "",
                 account_type: "checking",
                 balance: nil,
                 currency: "BRL",
                 description: "",
                 request_id: "",
                 routing_number: "",
                 status: nil,
                 transactions: %{
                   end_date: nil,
                   list: [],
                   start_date: nil
                 }
               }
             ]
    end

    test "raise exception for invalid staus code" do
      bank_msg = """
      <BANKMSGSRSV1>
      <STMTTRNRS>
      <STATUS>
      <CODE>invalid</CODE>
      <SEVERITY>INFO</SEVERITY>
      </STATUS>
      <STMTRS>
      <CURDEF>BRL</CURDEF>
      <BANKACCTFROM>
      <ACCTTYPE>CHECKING</ACCTTYPE>
      </BANKACCTFROM>
      <LEDGERBAL>
      <BALAMT>6151.76</BALAMT>
      <DTASOF>20210218100000[-03:EST]</DTASOF>
      </LEDGERBAL>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      """

      bank_example =
        bank_msg
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//BANKMSGSRSV1")

      assert_raise Error, "Invalid status code", fn ->
        Bank.format(bank_example)
      end
    end

    test "raise exception for invalid staus severity" do
      bank_msg = """
      <BANKMSGSRSV1>
      <STMTTRNRS>
      <STATUS>
      <CODE>0</CODE>
      <SEVERITY>invalid</SEVERITY>
      </STATUS>
      <STMTRS>
      <CURDEF>BRL</CURDEF>
      <BANKACCTFROM>
      <ACCTTYPE>CHECKING</ACCTTYPE>
      </BANKACCTFROM>
      <LEDGERBAL>
      <BALAMT>6151.76</BALAMT>
      <DTASOF>20210218100000[-03:EST]</DTASOF>
      </LEDGERBAL>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      """

      bank_example =
        bank_msg
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//BANKMSGSRSV1")

      assert_raise Error, "Severity is unknown", fn ->
        Bank.format(bank_example)
      end
    end

    test "raise exception for invalid amount" do
      bank_msg = """
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
      <LEDGERBAL>
      <BALAMT>NaN</BALAMT>
      </LEDGERBAL>
      </STMTRS>
      </STMTTRNRS>
      </BANKMSGSRSV1>
      """

      bank_example =
        bank_msg
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//BANKMSGSRSV1")

      assert_raise Error, "Amount is invalid or was not found", fn ->
        Bank.format(bank_example)
      end
    end
  end
end
