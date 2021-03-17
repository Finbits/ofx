defmodule Ofx.Parser.SweetXmlHandler do
  def handle({:fatal, {{:endtag_does_not_match, tag}, _file, _line, col}}, xml) do
    {:was, found, :should_have_been, expected} = tag

    {:error,
     %{
       message: "Missing tag end. Expected: #{expected}. Found: #{found}.",
       data: {xml, col}
     }}
  end

  def handle({:fatal, {:expected_element_start_tag, _file, _line, col}}, xml) do
    {:error, %{message: "Missing a start tag", data: {xml, col}}}
  end

  # {:fatal, {:unexpected_end, {:file, :file_name_unknown}, {:line, 1}, {:col, 224}}}
end
