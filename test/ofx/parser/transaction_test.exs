defmodule Ofx.Parser.TransactionTest do
  use ExUnit.Case, async: true

  import SweetXml, only: [sigil_x: 2]

  alias Ofx.Parser.Transaction

  describe "format/2" do
    test "format transaction" do
      currency = "BRL"

      transaction_example =
        "test/support/fixtures/bankmsgsrsv1.example"
        |> File.read!()
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//OFX/BANKMSGSRSV1/STMTTRNRS/STMTRS/BANKTRANLIST/STMTTRN")

      result = Transaction.format(transaction_example, currency)

      assert result == %{
               fit_id: "20210121001",
               check_number: "20210121001",
               memo: "DA  COMGAS 39309134",
               name: "",
               posted_date: ~N[2021-01-21 07:00:00],
               type: "debit",
               currency: "BRL",
               amount: -34.34,
               int_positive_amount: 3434,
               amount_type: :debit
             }
    end

    test "ignore default currency and use transaction currency" do
      currency = "BRL"

      transactions_example =
        "test/support/fixtures/transaction_with_currency.example"
        |> File.read!()
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//OFX/STMTTRN"l)

      result = Enum.map(transactions_example, &Transaction.format(&1, currency))

      assert result == [
               %{
                 fit_id: "20210121001",
                 check_number: "20210121001",
                 memo: "DA  COMGAS 39309134",
                 name: "",
                 posted_date: ~N[2021-01-21 07:00:00],
                 type: "debit",
                 currency: "BHD",
                 amount: -34.34,
                 int_positive_amount: 34340,
                 amount_type: :debit
               },
               %{
                 fit_id: "20210121001",
                 check_number: "20210121001",
                 memo: "DA  COMGAS 39309134",
                 name: "",
                 posted_date: ~N[2021-01-21 07:00:00],
                 type: "credit",
                 currency: "CVE",
                 amount: 34.0,
                 int_positive_amount: 34,
                 amount_type: :credit
               }
             ]
    end

    test "handle types" do
      currency = "BRL"

      transactions_example =
        "test/support/fixtures/transactions_with_different_types.example"
        |> File.read!()
        |> SweetXml.parse()
        |> SweetXml.xpath(~x"//OFX/STMTTRN"l)

      result = Enum.map(transactions_example, &Transaction.format(&1, currency))

      assert result == [
               %{
                 amount: 34.0,
                 amount_type: :credit,
                 check_number: "20210121001",
                 currency: "BRL",
                 fit_id: "20210121001",
                 int_positive_amount: 3400,
                 memo: "DA  COMGAS 39309134",
                 name: "",
                 posted_date: ~N[2021-01-21 07:00:00],
                 type: "interest"
               },
               %{
                 amount: 34.0,
                 amount_type: :credit,
                 check_number: "20210121001",
                 currency: "BRL",
                 fit_id: "20210121001",
                 int_positive_amount: 3400,
                 memo: "DA  COMGAS 39309134",
                 name: "",
                 posted_date: ~N[2021-01-21 07:00:00],
                 type: "dividend"
               },
               %{
                 amount: 34.0,
                 amount_type: :credit,
                 check_number: "20210121001",
                 currency: "BRL",
                 fit_id: "20210121001",
                 int_positive_amount: 3400,
                 memo: "DA  COMGAS 39309134",
                 name: "",
                 posted_date: ~N[2021-01-21 07:00:00],
                 type: "point_of_sale"
               }
             ]
    end
  end
end
