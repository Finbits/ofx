defmodule Ofx.Parser.Utils do
  @moduledoc false

  def remove_special_chars(string),
    do: String.replace(string, ~r/(?!&amp;)&/, "&amp;")

  def remove_white_spaces(string) do
    string
    |> String.replace(~r/>\s+</m, "><")
    |> String.replace(~r/\s+</m, "<")
    |> String.replace(~r/>\s+/m, ">")
  end

  def remove_file_headers(ofx_data),
    do: String.replace(ofx_data, ~r/^(.*?)<OFX>/s, "<OFX>")

  def write_close_tags(raw_data) do
    tags = find_all_tags(raw_data)

    replace_regex = ~r/<(#{tags})>([^<]+)(<\/(#{tags})>)?/

    String.replace(raw_data, replace_regex, "<\\1>\\2</\\1>")
  end

  defp find_all_tags(data) do
    ~r/<(\w+)>/
    |> Regex.scan(data, capture: :all_but_first)
    |> Enum.concat()
    |> Enum.uniq()
    |> Enum.reject(&already_closed(&1, data))
    |> Enum.join("|")
  end

  defp already_closed(tag, data) do
    open_count = ~r/<#{tag}>/ |> Regex.scan(data) |> length()
    close_count = ~r/<\/#{tag}>/ |> Regex.scan(data) |> length()

    close_count >= open_count
  end
end
