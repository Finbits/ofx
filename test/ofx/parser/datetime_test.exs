defmodule Ofx.Parser.DateTimeTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.{Datetime, Error}

  describe "format/1" do
    test "format datetime without timezone" do
      without_tz = "20150730100000"

      assert Datetime.format(without_tz) ==
               %DateTime{
                 year: 2015,
                 month: 7,
                 day: 30,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: 0,
                 std_offset: 0
               }
    end

    test "format datetime with positive timezone" do
      positive_tz = "20210218100000[+05:UTC]"

      assert Datetime.format(positive_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: 5 * 3600,
                 std_offset: 0
               }
    end

    test "format datetime with positive fractional timezone" do
      positive_fractional_tz = "20210218100000[03.30:UTC]"

      assert Datetime.format(positive_fractional_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: 12_600,
                 std_offset: 0
               }
    end

    test "format datetime with negative timezone" do
      negative_tz = "20210218100000[-03:UTC]"

      assert Datetime.format(negative_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: -10_800,
                 std_offset: 0
               }
    end

    test "format datetime with negative fractional timezone" do
      negative_fractional_tz = "20210218100000[-03.30:UTC]"

      assert Datetime.format(negative_fractional_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: -12_600,
                 std_offset: 0
               }
    end

    test "format datetime with miliseconds" do
      miliseconds_and_tz = "20210218163742.733[-4:UTC]"

      assert Datetime.format(miliseconds_and_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 16,
                 minute: 37,
                 second: 42,
                 microsecond: {733_000, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: -14_400,
                 std_offset: 0
               }
    end

    test "format date without time" do
      date_without_time = "20210218"

      assert Datetime.format(date_without_time) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 0,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: 0,
                 std_offset: 0
               }
    end

    test "format EST timezone" do
      est_tz = "20210218100000[-05:EST]"

      assert Datetime.format(est_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "EST",
                 zone_abbr: "EST",
                 utc_offset: -18_000,
                 std_offset: 0
               }
    end

    test "format unknown timezones as UTC" do
      edt_tz = "20210218100000[-04:EDT]"

      assert Datetime.format(edt_tz) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "UTC",
                 zone_abbr: "UTC",
                 utc_offset: -14_400,
                 std_offset: 0
               }
    end

    test "format positive GMT timezone" do
      positive_gmt = "20210218100000[03:GMT]"

      assert Datetime.format(positive_gmt) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "GMT",
                 zone_abbr: "GMT",
                 utc_offset: 10_800,
                 std_offset: 0
               }
    end

    test "format negative GMT timezone" do
      negative_gmt = "20210218100000[-03:GMT]"

      assert Datetime.format(negative_gmt) ==
               %DateTime{
                 year: 2021,
                 month: 2,
                 day: 18,
                 hour: 10,
                 minute: 0,
                 second: 0,
                 microsecond: {0, 3},
                 time_zone: "GMT",
                 zone_abbr: "GMT",
                 utc_offset: -10_800,
                 std_offset: 0
               }
    end

    test "raise exception when given value is nil" do
      assert_raise Error, "Date has invalid format or was not found", fn ->
        Datetime.format(nil)
      end
    end

    test "raise exception when given value is an empty string" do
      assert_raise Error, "Date has invalid format or was not found", fn ->
        Datetime.format("")
      end
    end

    test "raise exception when date format is invalid" do
      assert_raise Error, "Date has invalid format or was not found", fn ->
        Datetime.format("2019-01-01 00:00:00")
      end
    end
  end
end
