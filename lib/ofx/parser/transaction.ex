defmodule Ofx.Parser.Transaction do
  import SweetXml, only: [sigil_x: 2]

  alias Ofx.Parser.{Currency, Datetime}

  @typ ~x"TRNTYPE/text()"s
  @posted_date ~x"DTPOSTED/text()"s
  @amount ~x"TRNAMT/text()"s
  @fit_id ~x"FITID/text()"s
  @name ~x"NAME/text()"s
  @memo ~x"MEMO/text()"s
  @check_number ~x"CHECKNUM/text()"s
  @currency ~x"CURRENCY/text()"s
  @original_currency ~x"ORIGCURRENCY/text()"s

  def format(xml, default_currency) do
    amount = get(xml, @amount)
    currency = define_currency(xml, default_currency)

    %{
      check_number: get(xml, @check_number),
      fit_id: get(xml, @fit_id),
      name: get(xml, @name),
      memo: get(xml, @memo),
      posted_date: xml |> get(@posted_date) |> Datetime.format(),
      amount: Currency.amount_to_float(amount),
      int_positive_amount: Currency.amount_to_positive_integer(amount, currency),
      amount_type: Currency.amount_type(amount),
      type: xml |> get(@typ) |> format_type(),
      currency: currency
    }
  end

  defp define_currency(xml, default) do
    currency = get(xml, @currency)
    original_currency = get(xml, @original_currency)

    cond do
      currency != "" -> currency
      original_currency != "" -> original_currency
      true -> default
    end
  end

  def format_type(type) do
    types = %{
      "CREDIT" => "credit",
      "DEBIT" => "debit",
      "INT" => "interest",
      "DIV" => "dividend",
      "FEE" => "financial_fee",
      "SRVCHG" => "service_charge",
      "DEP" => "deposit",
      "ATM" => "ATM",
      "POS" => "point_of_sale",
      "XFER" => "transfer",
      "CHECK" => "check",
      "PAYMENT" => "electronic_payment",
      "CASH" => "cash_withdrawal",
      "DIRECTDEP" => "direct_deposit",
      "DIRECTDEBIT" => "merchant_initiated_debit",
      "REPEATPMT" => "repeating_payment_order",
      "HOLD" => "hold",
      "OTHER" => "other"
    }

    types[type]
  end

  defp get(xml, expression), do: SweetXml.xpath(xml, expression)
end
