defmodule Ofx.Parser.Bank do
  @moduledoc false

  import SweetXml, only: [sigil_x: 2]

  alias Ofx.Parser.{Currency, Datetime, Status, Transaction}

  @statements ~x"./STMTTRNRS"l
  @account_id ~x"//ACCTID/text()"s
  @balance ~x"//BALAMT/text()"s
  @balance_date ~x"//DTASOF/text()"s
  @currency ~x"//CURDEF/text()"s
  @account_type ~x"//ACCTTYPE/text()"s
  @description ~x"//DESC/text()"s
  @request_id ~x"//TRNUID/text()"s
  @routing_number ~x"//BANKID/text()"s
  @status_code ~x"//CODE/text()"s
  @status_severity ~x"//SEVERITY/text()"s
  @start_date ~x"//BANKTRANLIST/DTSTART/text()"s
  @end_date ~x"//BANKTRANLIST/DTEND/text()"s
  @transactions ~x"//BANKTRANLIST/STMTTRN"l

  @account_types %{
    "CHECKING" => "checking",
    "SAVINGS" => "savings",
    "MONEYMRKT" => "money_market",
    "CREDITLINE" => "line_of_credit",
    "CD" => "certificate_of_deposit"
  }

  def format(xml) do
    xml
    |> get(@statements)
    |> Enum.map(&format_statement/1)
  end

  def append_message(bank_messages, messages) do
    Map.update(messages, :bank, bank_messages, fn list -> Enum.concat(bank_messages, list) end)
  end

  defp format_statement(xml) do
    balance = get(xml, @balance)
    balance_date = get(xml, @balance_date)
    currency = get(xml, @currency)

    %{
      request_id: get(xml, @request_id),
      routing_number: get(xml, @routing_number),
      account_id: get(xml, @account_id),
      account_type: xml |> get(@account_type) |> format_account_type(),
      description: get(xml, @description),
      currency: currency,
      balance: build_balance(balance, balance_date, currency),
      status: %{
        code: xml |> get(@status_code) |> String.to_integer(),
        severity: xml |> get(@status_severity) |> Status.format_severity()
      },
      transactions: %{
        start_date: get_and_format_date(xml, @start_date),
        end_date: get_and_format_date(xml, @end_date),
        list: xml |> get(@transactions) |> Enum.map(&Transaction.format(&1, currency))
      }
    }
  end

  defp build_balance(balance, balance_date, currency) do
    %{
      date: Datetime.format(balance_date),
      amount: Currency.amount_to_float(balance),
      int_positive_amount: Currency.amount_to_positive_integer(balance, currency),
      amount_type: Currency.amount_type(balance)
    }
  end

  defp format_account_type(type), do: @account_types[type]

  defp get(xml, expression), do: SweetXml.xpath(xml, expression)

  defp get_and_format_date(xml, expression) do
    case get(xml, expression) do
      "" -> nil
      date -> Datetime.format(date)
    end
  end
end
