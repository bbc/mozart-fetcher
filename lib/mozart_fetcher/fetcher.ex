defmodule MozartFetcher.Fetcher do
  alias MozartFetcher.{Component}

  def process([]) do
    Stump.log(:error, %{message: "Error cannot process empty component list"})
    {:error}
  end

  def process(components) do
    components
    |> Enum.map(&Task.async(fn -> Component.fetch(&1) end))
    |> Enum.map(fn task -> Task.await(task, 10000) end)
    |> decorate_response
    |> Poison.encode!()
  end

  defp decorate_response(envelopes) do
    %{components: envelopes}
  end
end
