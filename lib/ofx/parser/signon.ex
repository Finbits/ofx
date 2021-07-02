defmodule Ofx.Parser.Signon do
  @moduledoc false

  import SweetXml, only: [sigil_x: 2]

  alias Ofx.Parser.{Datetime, Error, Status}

  @export_date ~x[SONRS/DTSERVER/text()]s
  @status ~x[SONRS/STATUS/CODE/text()]s
  @severity ~x[SONRS/STATUS/SEVERITY/text()]s
  @message ~x[SONRS/STATUS/MESSAGE/text()]s
  @language ~x[SONRS/LANGUAGE/text()]s
  @financial_institution ~x[SONRS/FI/ORG/text()]s

  def format(xml) do
    status_code = get(xml, @status)
    status_severity = get(xml, @severity)
    status_message = get(xml, @message)
    language = get(xml, @language)
    financial_institution = get(xml, @financial_institution)
    export_date = get_and_format_export_date(xml, @export_date)

    %{
      export_date: export_date,
      status_code: String.to_integer(status_code),
      status_severity: Status.format_severity(status_severity),
      status_message: status_message,
      language: language,
      financial_institution: financial_institution
    }
  rescue
    error in Error -> reraise error, __STACKTRACE__
    _any -> reraise Error, %{message: "Invalid SIGNON message", data: ""}, __STACKTRACE__
  end

  def append_message(%{} = signon, %{} = messages),
    do: Map.put(messages, :signon, signon)

  defp get(xml, expression), do: SweetXml.xpath(xml, expression)

  defp get_and_format_export_date(xml, expression) do
    xml
    |> get(expression)
    |> Datetime.format()
  rescue
    _error -> nil
  end
end
