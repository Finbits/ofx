defmodule Ofx.Parser.SweetXmlHandler do
  @moduledoc false

  def handle({:fatal, {{:endtag_does_not_match, tag}, _file, _line, col}}, xml) do
    {:was, found, :should_have_been, expected} = tag

    {:error,
     %{
       message: "Missing tag end. Expected: #{expected}. Found: #{found}.",
       data: {xml, col}
     }}
  end

  def handle({:fatal, {:unexpected_end, _file, _line, col}}, xml) do
    {:error, %{message: "A tag has ended unexpectedly", data: {xml, col}}}
  end

  def handle({:fatal, {:expected_element_start_tag, _file, _line, col}}, xml) do
    {:error, %{message: "Missing a start tag", data: {xml, col}}}
  end

  def handle(error, _xml), do: {:error, %{message: "Unknown error", data: error}}
end
