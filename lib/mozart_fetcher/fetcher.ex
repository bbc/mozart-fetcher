defmodule MozartFetcher.Fetcher do
  alias MozartFetcher.{Component, TimeoutParser}

  use ExMetrics

  def process([]) do
    ExMetrics.increment("error.empty_component_list")
    Stump.log(:error, %{message: "Error cannot process empty component list"})
    {:error}
  end

  def process(components) do
    ExMetrics.timeframe "function.timing.fetcher.process" do
      max_timeout = TimeoutParser.max(components)

      components
      |> Enum.with_index()
      |> Task.async_stream(&Component.fetch/1, timeout: max_timeout,  on_timeout: :kill_task, max_concurrency: 40)
      |> Enum.to_list
      |> extract_successful
      |> decorate_response
      |> Jason.encode!()
    end
  end

  defp decorate_response(envelopes) do
    %{components: envelopes}
  end

  defp extract_successful(components) do
    {oks, errors} = Enum.split_with(components, fn {k, _v} -> k == :ok end)

    errors |> Enum.each(&log(&1))
    oks |> Enum.map(fn({:ok, result}) -> result end)
  end

  defp log({type, error}) do
    Stump.log(:error, %{message: "Component Process Error", type: type, error: error })
  end
end
