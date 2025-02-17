defmodule Ofx do
  @moduledoc false

  defdelegate parse(ofx), to: Ofx.Parser
  defdelegate parse!(ofx), to: Ofx.Parser
end
