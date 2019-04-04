defmodule MozartFetcher.Envelope do
  alias MozartFetcher.{Envelope, Decoder}

  @derive Jason.Encoder
  defstruct head: [], bodyInline: "", bodyLast: []

  def build(body) do
    case Decoder.data_to_struct(body, as: %Envelope{}) do
      {:ok, envelope} ->
        ExMetrics.increment("success.envelope.decode")
        envelope
      {:error}    ->
        ExMetrics.increment("error.envelope.decode")
        Stump.log(:error, %{message: "Failed to decode Envelope", body: body})
        %Envelope{}
    end
  end
end
