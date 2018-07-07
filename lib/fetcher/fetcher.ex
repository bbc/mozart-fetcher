defmodule Fetcher.Fetcher do
  def process(components = [%Component{}]) do
    components
    |> Enum.map(&Task.async(fn -> fetch(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.join(" ")
  end

  def process([]) do
    IO.puts "boo empty"
  end

  defp fetch(component = %Component{}) do
    headers = []
    options = [recv_timeout: 3000]

    {:ok, resp} = HTTPoison.get(component.endpoint, headers, options)
    resp.body
  end
end
