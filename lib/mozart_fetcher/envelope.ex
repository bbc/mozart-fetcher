defmodule MozartFetcher.Envelope do
  alias MozartFetcher.{Envelope}

  defstruct [head: [], bodyInline: "", bodyLast: []]

  def build(_body = nil)do
    %Envelope{}
  end

  def build(body) do
    case Poison.decode(body, as: %Envelope{}) do
      {:ok, envelope = %Envelope{}} -> envelope
      {:error, _}                   -> %Envelope{}
    end
  end
end
