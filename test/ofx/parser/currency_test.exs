defmodule Ofx.Parser.CurrencyTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.{Currency, Error}

  describe "amount_to_positive_integer/2" do
    test "convert successfully when there is no decimals" do
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

    test "convert successfully when there is 2 decimals" do
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

    test "convert successfully when there is 3 decimals" do
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

    test "convert considering 2 decimals as default when currency is empty" do
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

    test "convert successfully when there R$ symbol" do
      currency = "BRL"
      without_decimal = "R$ 500"
      one_decimal = "R$500.1"
      two_decimals = "R$ 500.10 "
      negative = "R$ -500.1"

      assert Currency.amount_to_positive_integer(without_decimal, currency) == 50_000
      assert Currency.amount_to_positive_integer(one_decimal, currency) == 50_010
      assert Currency.amount_to_positive_integer(two_decimals, currency) == 50_010
      assert Currency.amount_to_positive_integer(negative, currency) == 50_010
    end

    test "raise exception when currency is invalid" do
      assert_raise Error, "Amount is invalid or currency is unknown", fn ->
        Currency.amount_to_positive_integer("100", "reais")
      end
    end

    test "raise exception when amount is invalid" do
      assert_raise Error, "Amount is invalid or currency is unknown", fn ->
        Currency.amount_to_positive_integer("a", "BRL")
      end
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
      negative_less_than_1_with_comma = "-0,87"
      positive_less_than_1_with_comma = "0,01"
      negative_less_than_1_with_dot = "-0.17"
      positive_less_than_1_with_dot = "0.09"

      assert Currency.amount_to_float(negative) == -90.0
      assert Currency.amount_to_float(negative_with_spaces) == -90.0
      assert Currency.amount_to_float(positive) == 90.0
      assert Currency.amount_to_float(positive_with_spaces) == 90.00
      assert Currency.amount_to_float(negative_less_than_1_with_comma) == -0.87
      assert Currency.amount_to_float(positive_less_than_1_with_comma) == 0.01
      assert Currency.amount_to_float(negative_less_than_1_with_dot) == -0.17
      assert Currency.amount_to_float(positive_less_than_1_with_dot) == 0.09
    end

    test "raise exception when amount is invalid" do
      assert_raise Error, "Amount is invalid or was not found", fn ->
        Currency.amount_to_float("a")
      end
    end
  end
end
