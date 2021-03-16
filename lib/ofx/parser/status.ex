defmodule Ofx.Parser.Status do
  @severities %{
    "INFO" => :info,
    "WARN" => :warn,
    "ERROR" => :error
  }

  def format_severity(severity), do: @severities[severity]
end
