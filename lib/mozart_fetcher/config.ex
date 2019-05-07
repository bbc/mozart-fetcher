defmodule MozartFetcher.Config do
  @derive Jason.Encoder
  defstruct [:endpoint, :id, :must_succeed, :format]
end
