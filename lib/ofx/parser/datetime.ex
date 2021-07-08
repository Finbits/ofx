defmodule Ofx.Parser.Datetime do
  @moduledoc false

  alias Ofx.Parser.Error

  defstruct [:input, :datetime_string, :date, :time, :offset, :timezone, :zone_abbreviation]

  # Parse OFX datetime string to formated DateTime struct
  #
  # Ex:
  #
  #    format("20210218100000[-05:EST]")
  #    => #DateTime<2021-02-18 10:00:00-05:00 EST>
  #
  #    format("20210218")
  #    => #DateTime<2021-02-18 00:00:00+00:00 UTC>
  #
  #    format("00000000")
  #    => (Ofx.Parser.Error) Date has invalid format or was not found
  def format(input) do
    %__MODULE__{input: input}
    |> extract_timezone()
    |> extract_date()
    |> extract_time()
    |> ensure_valid_timezone()
    |> to_datetime()
  rescue
    _any ->
      reraise(
        Error,
        %{message: "Date has invalid format or was not found", data: input},
        __STACKTRACE__
      )
  end

  # Extract datetime and timezone attributes
  #
  # Ex:
  #
  #    extract_timezone(%{input: "20210218100000[-04:EDT]"})
  #    => %{
  #      datetime_string: "20210218100000",
  #      timezone: "EDT",
  #      offset: "-04"
  #    }
  #
  #    extract_timezone(%{input: "20170113120000"})
  #    => %{
  #      datetime_string: "20170113120000",
  #      timezone: "UTC",
  #      offset: "0"
  #    }
  #
  #    extract_timezone(%{input: "20210218"})
  #    => %{
  #      datetime_string: "20210218",
  #      timezone: "UTC",
  #      offset: "0"
  #    }
  defp extract_timezone(%{input: input} = token) do
    case String.split(input, ["[", ":", "]"], trim: true) do
      [datetime_string, offset, timezone] ->
        %{
          token
          | datetime_string: datetime_string,
            offset: offset,
            timezone: timezone
        }

      [datetime_string] ->
        %{
          token
          | datetime_string: datetime_string,
            offset: "0",
            timezone: "UTC"
        }
    end
  end

  # Build and validate date struct
  #
  # Ex:
  #
  #    extract_date(%{datetime_string: "20210218100000"})
  #    => %{
  #      date: ~D[2021-02-18],
  #    }
  #
  #    extract_date(%{datetime_string: "20210218"})
  #    => %{
  #      date: ~D[2021-02-18],
  #    }
  #
  #    extract_date(%{datetime_string: "00000000"})
  #    => (ArgumentError) cannot build date, reason: :invalid_date
  defp extract_date(%{datetime_string: datetime_string} = token) do
    {date_string, _time} = String.split_at(datetime_string, 8)

    %{
      token
      | date:
          Date.new!(
            to_integer(date_string, 0..3),
            to_integer(date_string, 4..5),
            to_integer(date_string, 6..7)
          )
    }
  end

  # Build and validate time struct
  #
  # Ex:
  #
  #    extract_time(%{datetime_string: "20210218100000"})
  #    => %{
  #      time: ~T[10:00:00],
  #    }
  #
  #    extract_time(%{datetime_string: "20210218"})
  #    => %{
  #      time: ~T[00:00:00],
  #    }
  #
  #    extract_time(%{datetime_string: "20210218999999"})
  #    => (ArgumentError) cannot build time, reason: :invalid_time
  defp extract_time(%{datetime_string: datetime_string} = token) do
    {_date, time_string} = String.split_at(datetime_string, 8)

    %{
      token
      | time:
          Time.new!(
            to_integer(time_string, 0..1),
            to_integer(time_string, 2..3),
            to_integer(time_string, 4..5)
          )
    }
  end

  # Ensure valid timezone, converting any "invalid/unknown" timezone to UTC
  #
  # Ex:
  #
  #    ensure_valid_timezone(%{timezone: "UTC"})
  #    => %{
  #      timezone: "UTC",
  #      zone_abbreviation: "UTC"
  #    }
  #
  #    ensure_valid_timezone(%{timezone: "EST"})
  #    => %{
  #      timezone: "EST",
  #      zone_abbreviation: "EST"
  #    }
  #
  #    ensure_valid_timezone(%{timezone: "UNKNOWN"})
  #    => %{
  #      timezone: "UTC",
  #      zone_abbreviation: "UTC"
  #    }
  defp ensure_valid_timezone(%{timezone: timezone} = token) do
    case Tzdata.periods(timezone) do
      {:ok, [%{zone_abbr: zone_abbr} | _]} ->
        %{token | zone_abbreviation: zone_abbr}

      {:error, :not_found} ->
        %{token | zone_abbreviation: "UTC", timezone: "UTC"}
    end
  end

  # Format output to DateTime
  #
  # Ex:
  #
  #    to_datetime(%{date: ~D[2021-02-18], time: ~T[10:00:00], offset: "-03", timezone: "UTC"})
  #    => #DateTime<2021-02-18 10:00:00-03:00 UTC>
  #
  defp to_datetime(%{
         date: date,
         time: time,
         offset: offset,
         timezone: timezone,
         zone_abbreviation: zone_abbreviation
       }) do
    %DateTime{
      year: date.year,
      month: date.month,
      day: date.day,
      hour: time.hour,
      minute: time.minute,
      second: time.second,
      time_zone: timezone,
      zone_abbr: zone_abbreviation,
      utc_offset: offset_in_seconds(offset),
      std_offset: 0
    }
  end

  defp to_integer(str), do: to_integer(str, 0..-1)

  defp to_integer("", _range), do: 0

  defp to_integer(str, range) do
    str
    |> String.slice(range)
    |> String.to_integer()
  end

  defp offset_in_seconds("-" <> offset), do: -offset_in_seconds(offset)

  defp offset_in_seconds(offset) do
    case String.split(offset, ".") do
      [hours] ->
        to_integer(hours) * 60 * 60

      [hours, minutes] ->
        hours_offset = to_integer(hours) * 60 * 60
        minutes_offset = to_integer(minutes) * 60

        hours_offset + minutes_offset
    end
  end
end
