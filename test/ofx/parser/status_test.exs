defmodule Ofx.Parser.StatusTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.{Error, Status}

  describe "format_severity/1" do
    test "return severity atom" do
      assert Status.format_severity("INFO") == :info
      assert Status.format_severity("WARN") == :warn
      assert Status.format_severity("ERROR") == :error
    end

    test "raise exception when given unknown severity" do
      assert_raise Error, "Severity is unknown", fn ->
        Status.format_severity("invalid")
      end
    end
  end
end
