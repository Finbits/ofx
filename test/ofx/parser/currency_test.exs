defmodule Ofx.Parser.CurrencyTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.Currency

  describe "amount_to_positive_integer/2" do
    test "to a currence with no decimals" do
      currency = "CVE"
      without_decimal = "500"
      one_decimal = "500.0"
      two_decimals = "500.00"
      negative = "-500.00"

      assert Currency.amount_to_positive_integer(without_decimal, currency) == 500
      assert Currency.amount_to_positive_integer(one_decimal, currency) == 500
      assert Currency.amount_to_positive_integer(two_decimals, currency) == 500
      assert Currency.amount_to_positive_integer(negative, currency) == 500
    end

    test "to a currence with 2 decimals" do
      currency = "BRL"
      without_decimal = "500"
      one_decimal = "500.1"
      two_decimals = "500.10"
      negative = "-500.1"

      assert Currency.amount_to_positive_integer(without_decimal, currency) == 50_000
      assert Currency.amount_to_positive_integer(one_decimal, currency) == 50_010
      assert Currency.amount_to_positive_integer(two_decimals, currency) == 50_010
      assert Currency.amount_to_positive_integer(negative, currency) == 50_010
    end

    test "to a currence with 3 decimals" do
      currency = "BHD"
      without_decimal = "500"
      one_decimal = "500.1"
      two_decimals = "500.10"
      three_decimals = "500.100"
      negative = "-500.1"

      assert Currency.amount_to_positive_integer(without_decimal, currency) == 500_000
      assert Currency.amount_to_positive_integer(one_decimal, currency) == 500_100
      assert Currency.amount_to_positive_integer(two_decimals, currency) == 500_100
      assert Currency.amount_to_positive_integer(three_decimals, currency) == 500_100
      assert Currency.amount_to_positive_integer(negative, currency) == 500_100
    end
  end

  describe "amount_type/1" do
    test "return amount type" do
      negative = "-90.00"
      negative_with_spaces = " - 90.00"
      positive = "90.00"
      positive_with_spaces = " 90.00"

      assert Currency.amount_type(negative) == :debit
      assert Currency.amount_type(negative_with_spaces) == :debit
      assert Currency.amount_type(positive) == :credit
      assert Currency.amount_type(positive_with_spaces) == :credit
    end
  end

  describe "amount_to_float/1" do
    test "return float" do
      negative = "-90.00"
      negative_with_spaces = " - 90.00"
      positive = "90.00"
      positive_with_spaces = " 90.00"

      assert Currency.amount_to_float(negative) == -90.0
      assert Currency.amount_to_float(negative_with_spaces) == -90.0
      assert Currency.amount_to_float(positive) == 90.0
      assert Currency.amount_to_float(positive_with_spaces) == 90.0
    end
  end
end
