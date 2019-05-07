defmodule MozartFetcher.Components.Envelope do
  alias MozartFetcher.{Components, Envelope}
  @moduledoc false
  @derive [Jason.Encoder]
  defstruct [:index, :id, :status, :envelope]
  @type t :: %Components.Envelope{index: non_neg_integer(), id: String.t(), status: non_neg_integer(), envelope: Envelope.t()}
end
