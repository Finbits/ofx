defmodule Ofx.Parser.Datetime do
  @moduledoc false

  alias Ofx.Parser.Error

  defstruct [
    :year,
    :month,
    :day,
    :hour,
    :minute,
    :second,
    :microsecond,
    :utc_offset,
    :time_zone,
    :zone_abbr,
    std_offset: 0,
    calendar: Calendar.ISO
  ]

  @datetime_regex ~r'^(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})?(?<minute>\d{2})?(?<second>\d{2})?\.?(?<microsecond>\d{3})?(\[(?<utc_offset>[-+]?\d{1,2}(\.\d{1,2})?)?:(?<time_zone>\w{3}))?'
  @doc """
  Regex explanation

  Is required the string stars with (by the operator ^) the date groups:
  - year: the first 4 digits - (?<year>\d{4})
  - month: the next 2 digits - (?<month>\d{2})
  - day: the next 2 digits - (?<day>\d{2})

  After the date groups we have the time gourps witch are optionals.
  They are matched after date groups as:

  - hour: the next 2 digits - (?<hour>\d{2})
  - minute: the next 2 digits - (?<minute>\d{2})
  - second: the next 2 digits - (?<second>\d{2})

  The microsecond is an optional group of time's groups. Its start delimitator
  is the \.?

  - microsecond: optional 3 digits after second group - \.?(?<microsecond>\d{3})?

  The timezone groups are optional too and they must came after time groups.
  Its start delimitator is the \[


  - utc_offset: came after the time groups.
    - It can have a numerical signal - [-+]?
    - It must have one or two digits for the hours- \d{1,2}
    - It can have one or two digits for the minutes delimited by \. - (\.\d{1,2})?
    - The entire group regex: (?<utc_offset>[-+]?\d{1,2}(\.\d{1,2})?)?
  - time_zone: the next 3 chars after the delimitator : - (?<time_zone>\w{3})
  """

  def format(input) when is_binary(input) do
    input
    |> format_date()
    |> to_struct()
    |> adjust_microsecond()
    |> adjust_time_zone()
    |> adjust_utc_offset()
    |> to_datetime()
    |> case do
      {:ok, datetime} -> datetime
      _error -> raise_error(input)
    end
  end

  def format(input), do: raise_error(input)

  defp format_date(input) do
    if Regex.match?(~r/^\d{2}\/\d{2}\/\d{4}$/, input) do
      [d, m, y] = String.split(input, "/")
      "#{y}#{m}#{d}"
    else
      input
    end
  end

  defp to_struct(input) do
    case Regex.named_captures(@datetime_regex, input) do
      nil ->
        {:error, "invalid datetime"}

      captured ->
        {:ok,
         %__MODULE__{
           year: get_int(captured, "year"),
           month: get_int(captured, "month"),
           day: get_int(captured, "day"),
           hour: get_int(captured, "hour"),
           minute: get_int(captured, "minute"),
           second: get_int(captured, "second"),
           microsecond: get_int(captured, "microsecond"),
           utc_offset: get(captured, "utc_offset", "0"),
           time_zone: get(captured, "time_zone", "UTC")
         }}
    end
  end

  defp adjust_microsecond({:error, _reason} = err), do: err

  defp adjust_microsecond({:ok, datetime_struct}) do
    microsecond = {datetime_struct.microsecond * 1000, 3}

    {:ok, %{datetime_struct | microsecond: microsecond}}
  end

  defp adjust_time_zone({:error, _reason} = err), do: err

  defp adjust_time_zone({:ok, datetime_struct}) do
    {time_zone, zone_abbr} = find_correct_time_zone_info(datetime_struct.time_zone)

    {:ok, %{datetime_struct | time_zone: time_zone, zone_abbr: zone_abbr}}
  end

  defp adjust_utc_offset({:error, _reason} = err), do: err

  defp adjust_utc_offset({:ok, datetime_struct}) do
    utc_offset = parse_utc_offset(datetime_struct.utc_offset)

    {:ok, %{datetime_struct | utc_offset: utc_offset}}
  end

  defp to_datetime({:error, _reason} = err), do: err

  defp to_datetime({:ok, %{year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0}}) do
    {:ok, nil}
  end

  defp to_datetime({:ok, datetime_struct}) do
    datetime = Map.put(datetime_struct, :__struct__, DateTime)

    datetime
    |> DateTime.to_iso8601()
    |> DateTime.from_iso8601()
    |> case do
      {:ok, _parsed_utc0_datetime, _offset} -> {:ok, datetime}
      {:error, reason} -> {:error, reason}
    end
  end

  defp find_correct_time_zone_info(time_zone) do
    case Tzdata.periods(time_zone) do
      {:ok, [found | _]} -> {time_zone, found.zone_abbr}
      {:error, :not_found} -> {"UTC", "UTC"}
    end
  end

  defp parse_utc_offset("-" <> utc_offset), do: -parse_utc_offset(utc_offset)

  defp parse_utc_offset(utc_offset) do
    case String.split(utc_offset, ".") do
      [hours] -> String.to_integer(hours) * 3600
      [hours, minutes] -> String.to_integer(hours) * 3600 + String.to_integer(minutes) * 60
    end
  end

  defp raise_error(input) do
    raise(Error, %{message: "Date has invalid format or was not found", data: input})
  end

  defp get_int(map, key), do: map |> get(key, "0") |> String.to_integer()

  defp get(map, key, default) do
    case Map.fetch!(map, key) do
      "" -> default
      value -> value
    end
  end
end
