defmodule Ofx.Parser.Datetime do
  @moduledoc false

  import String, only: [to_integer: 1]

  alias Ofx.Parser.Error

  @regex ~r'^(?<y>\d{4})(?<M>\d{2})(?<d>\d{2})(?<h>\d{2})?(?<m>\d{2})?(?<s>\d{2})?(\.\d{3})?.*?(\[(?<signal>[-+]?)(?<th>\d{1,2})\.?(?<tm>\d{1,2})?)?'

  @seconds_in_an_hour 3600
  @seconds_in_a_minute 60

  def format(date_string) do
    @regex
    |> Regex.named_captures(date_string)
    |> build_naive_date_time()
    |> shift_tz_to_uct0()
  rescue
    _any ->
      reraise Error,
              %{message: "Date has invalid format or was not found", data: date_string},
              __STACKTRACE__
  end

  defp build_naive_date_time(%{} = captures) do
    naivedatetime =
      NaiveDateTime.new!(
        get_as_int(captures, "y"),
        get_as_int(captures, "M"),
        get_as_int(captures, "d"),
        get_as_int(captures, "h", 0),
        get_as_int(captures, "m", 0),
        get_as_int(captures, "s", 0)
      )

    {captures, naivedatetime}
  end

  defp get_as_int(map, key, default \\ nil) do
    value = Map.get(map, key)

    if value == "" or value == nil do
      default
    else
      to_integer(value)
    end
  end

  defp shift_tz_to_uct0({%{"th" => ""}, naivedatetime}), do: naivedatetime

  defp shift_tz_to_uct0({captures, naivedatetime}),
    do: NaiveDateTime.add(naivedatetime, calcule_tz(captures), :second)

  defp calcule_tz(%{"th" => hours, "tm" => minutes, "signal" => signal}) do
    minute_seconds = calcule_minutes(minutes)

    hour_seconds = to_integer(hours) * @seconds_in_an_hour

    apply_signal(hour_seconds + minute_seconds, signal)
  end

  defp calcule_minutes(""), do: 0
  defp calcule_minutes(minutes), do: to_integer(minutes) * @seconds_in_a_minute

  defp apply_signal(seconds, "-"), do: -seconds
  defp apply_signal(seconds, _signal), do: seconds
end
