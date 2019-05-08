defmodule MozartFetcher.Components.Envelope do
  alias MozartFetcher.Envelope
  @moduledoc false
  @derive [Jason.Encoder]
  defstruct [:index, :id, :status, :envelope]
  @type t :: %__MODULE__{index: non_neg_integer(), id: String.t(), status: non_neg_integer(), envelope: Envelope.t()}
end
