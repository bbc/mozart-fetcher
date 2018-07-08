defmodule MozartFetcher.Fetcher do
  alias MozartFetcher.{Component, Envelope}

  def process([]) do
    {:error}
  end

  def process(components) do
    components
    |> Enum.map(&Task.async(fn -> Component.fetch(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(Envelope.build)
    |> Enum.join(" ")
  end
end
