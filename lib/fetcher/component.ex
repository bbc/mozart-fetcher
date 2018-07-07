defmodule Component do
  @derive [Poison.Encoder]
  defstruct [:endpoint, :id, :must_succed]
end
