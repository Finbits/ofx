defmodule Ofx.Parser do
  import Ofx.Parser.Utils

  import SweetXml, only: [xpath: 2, sigil_x: 2]

  alias Ofx.Parser.{Bank, Error, Signon, SweetXmlHandler}

  @message_list ~x"//OFX/*[contains(name(),'MSGSRS')]"l
  @message_name ~x"name()"s

  def parse(raw_data) when is_binary(raw_data) do
    xml_data = normalize_to_xml(raw_data)

    try do
      xml_data
      |> SweetXml.parse()
      |> format_messages()
      |> (&{:ok, &1}).()
    rescue
      error in Error -> {:error, Map.take(error, [:message, :data])}
    catch
      :exit, error -> SweetXmlHandler.handle(error, xml_data)
    end
  end

  def parse!(raw_data) when is_binary(raw_data) do
    case parse(raw_data) do
      {:ok, result} -> result
      {:error, error} -> raise Error, error
    end
  end

  defp normalize_to_xml(raw_data) do
    raw_data
    |> remove_file_headers()
    |> remove_white_spaces()
    |> write_close_tags()
    |> remove_special_chars()
  end

  defp format_messages(xml_data) do
    xml_data
    |> xpath(@message_list)
    |> Enum.reduce(%{}, &format_message(xpath(&1, @message_name), &1, &2))
  end

  defp format_message("SIGNONMSGSRSV1", xml_data, messages) do
    xml_data
    |> Signon.format()
    |> Signon.append_message(messages)
  end

  defp format_message("BANKMSGSRSV1", xml_data, messages) do
    xml_data
    |> Bank.format()
    |> Bank.append_message(messages)
  end

  defp format_message(_unknowmessage, _xml, formated_messages), do: formated_messages
end
