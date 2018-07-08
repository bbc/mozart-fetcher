defmodule MozartFetcher.Envelope do
  alias MozartFetcher.{Envelope}
  @derive [Poison.Encoder]
  defstruct head: [], bodyInline: "", bodyLast: []

  def build({:ok, body}) do
    case Poison.decode(body, as: %Envelope{}) do
      {:ok, envelope = %Envelope{}} -> envelope
      {:error, _}                   -> %Envelope{}
    end
  end

  def build({:error, _reason}) do
    %Envelope{}
  end
end
