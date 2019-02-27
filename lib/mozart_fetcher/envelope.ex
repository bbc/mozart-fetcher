defmodule MozartFetcher.Envelope do
  alias MozartFetcher.{Envelope}

  @derive [Poison.Encoder]
  defstruct head: [], bodyInline: "", bodyLast: []

  def build(body) do
    case Poison.decode(body, as: %Envelope{}) do
      {:ok, envelope = %Envelope{}} ->
        ExMetrics.increment(:"success.envelope.decode")
        envelope

      {:error, _, _} ->
        ExMetrics.increment(:"error.envelope.decode")
        %Envelope{}
    end
  end
end
