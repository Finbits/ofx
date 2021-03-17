defmodule Ofx.Parser.Status do
  @moduledoc false

  alias Ofx.Parser.Error

  @severities %{
    "INFO" => :info,
    "WARN" => :warn,
    "ERROR" => :error
  }

  def format_severity(severity) do
    Map.fetch!(@severities, severity)
  rescue
    _any -> reraise Error, %{message: "Severity is unknown", data: severity}, __STACKTRACE__
  end
end
