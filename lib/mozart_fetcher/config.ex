defmodule MozartFetcher.Config do
  @derive Jason.Encoder
  defstruct [:endpoint, :id, :must_succed]
end
