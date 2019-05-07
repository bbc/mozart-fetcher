defmodule MozartFetcher.Components.Ares do
  alias MozartFetcher.Components.Ares
  @moduledoc false
  @derive [Jason.Encoder]
  defstruct [:index, :id, :status, :data]
  @type t :: %Ares{index: non_neg_integer(), id: String.t(), status: non_neg_integer(), data: Map.t()}
end
