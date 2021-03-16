defmodule Ofx.Parser.DateTimeTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.Datetime

  describe "format/1" do
    test "format ofx date to naivedatetime" do
      without_tz = "20150730120000"
      positive_tz = "20210218100000[03:EST]"
      positive_fractional_tz = "20210218100000[03.30:EST]"
      negative_tz = "20210218100000[-03:EST]"
      negative_fractional_tz = "20210218100000[-03.30:EST]"
      miliseconds_and_tz = "20170727163742.733[-4:EDT]"

      assert Datetime.format(without_tz) == ~N[2015-07-30 12:00:00]
      assert Datetime.format(positive_tz) == ~N[2021-02-18 13:00:00]
      assert Datetime.format(positive_fractional_tz) == ~N[2021-02-18 13:30:00]
      assert Datetime.format(negative_tz) == ~N[2021-02-18 07:00:00]
      assert Datetime.format(negative_fractional_tz) == ~N[2021-02-18 06:30:00]
      assert Datetime.format(miliseconds_and_tz) == ~N[2017-07-27 12:37:42]
    end
  end
end
