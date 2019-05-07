defmodule MozartFetcher.Components.EnvelopeComponent do
  alias MozartFetcher.{Components.EnvelopeComponent, Envelope}
  @moduledoc false
  @derive [Jason.Encoder]
  defstruct [:index, :id, :status, :envelope]
  @type t :: %EnvelopeComponent{index: non_neg_integer(), id: String.t(), status: non_neg_integer(), envelope: Envelope.t()}
end
