defmodule Ofx.Parser.Status do
  alias Ofx.Parser.Error

  @severities %{
    "INFO" => :info,
    "WARN" => :warn,
    "ERROR" => :error
  }

  def format_severity(severity) do
    Map.fetch!(@severities, severity)
  rescue
    _any -> raise Error, %{message: "Severity is unknown", data: severity}
  end
end
