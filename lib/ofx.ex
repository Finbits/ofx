defmodule Ofx do
  defdelegate parse(ofx), to: Ofx.Parser
  defdelegate parse!(ofx), to: Ofx.Parser
end
