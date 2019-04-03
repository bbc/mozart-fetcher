defmodule MozartFetcher.Envelope do
  alias MozartFetcher.{Envelope}

  @derive [Jason.Encoder]
  defstruct head: [], bodyInline: "", bodyLast: []

  def build(body) do
    case Poison.decode(body, as: %Envelope{}) do
      {:ok, envelope = %Envelope{}} ->
        envelope

      {:error, _, _} ->
        Stump.log(:error, %{message: "Failed to decode Envelope", body: body})
        %Envelope{}
    end
  end
end
