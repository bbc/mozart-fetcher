defmodule MozartFetcher.Components.Ares do
  @moduledoc false
  @derive [Jason.Encoder]
  defstruct [:index, :id, :status, :data]
  @type t :: %__MODULE__{index: non_neg_integer(), id: String.t(), status: non_neg_integer(), data: Map.t()}
end
