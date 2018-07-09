defmodule MozartFetcher.Fetcher do
  alias MozartFetcher.{Component}

  def process([]) do
    {:error}
  end

  def process(components) do
    components
    |> Enum.map(&Task.async(fn -> Component.fetch(&1) end))
    |> Enum.map(&Task.await/1)
    |> decorate_response
    |> Poison.encode!()
  end

  defp decorate_response(envelopes) do
    %{components: envelopes}
  end
end
