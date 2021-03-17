defmodule Ofx.SweetXmlHandlerTest do
  use ExUnit.Case, async: true

  alias Ofx.Parser.SweetXmlHandler

  describe "handle/2" do
    test "handle end tag error" do
      error =
        {:fatal,
         {{:endtag_does_not_match, {:was, :SIGNONMSGSRSV1, :should_have_been, :OFX}},
          {:file, :file_name_unknown}, {:line, 1}, {:col, 145}}}

      result = SweetXmlHandler.handle(error, "")

      assert result ==
               {:error,
                %{
                  data: {"", {:col, 145}},
                  message: "Missing tag end. Expected: OFX. Found: SIGNONMSGSRSV1."
                }}
    end

    test "handle start tag error" do
      error =
        {:fatal,
         {:expected_element_start_tag, {:file, :file_name_unknown}, {:line, 1}, {:col, 2}}}

      result = SweetXmlHandler.handle(error, "")

      assert result == {:error, %{data: {"", {:col, 2}}, message: "Missing a start tag"}}
    end

    test "handle unexpected end" do
      error = {:fatal, {:unexpected_end, {:file, :file_name_unknown}, {:line, 1}, {:col, 224}}}

      result = SweetXmlHandler.handle(error, "")

      assert result ==
               {:error, %{data: {"", {:col, 224}}, message: "A tag has ended unexpectedly"}}
    end
  end
end
