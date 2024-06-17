defmodule MozartFetcher.Envelope do
  alias MozartFetcher.{Envelope, Decoder}

  @derive Jason.Encoder
  defstruct head: [], bodyInline: "", bodyLast: []

  def build(body) do
    case Decoder.decode_envelope(body, %Envelope{}) do
      {:ok, envelope} ->
        :telemetry.execute([:success, :envelope, :decode], %{})
        envelope

      {:error} ->
        :telemetry.execute([:error, :envelope, :decode], %{})
        %Envelope{}
    end
  end
end
