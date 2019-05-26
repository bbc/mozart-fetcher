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
      stream_opts = [timeout: max_timeout, on_timeout: :kill_task, max_concurrency: 40]

      components
      |> Enum.with_index()
      |> Task.async_stream(&Component.fetch/1, stream_opts)
      |> Enum.to_list()
      |> extract_successful()
      |> decorate_response()
      |> Jason.encode!()
    end
  end

  defp decorate_response(envelopes) do
    %{components: envelopes}
  end

  # returns the successful one (including 500 etc) and logs
  # the tasks which have not completed.
  # At the moment it's in form  of `[exit: :timeout]` so hard to
  # easily log which component has failed.
  defp extract_successful(responses) do
    {oks, errors} = Enum.split_with(responses, fn {k, _v} -> k == :ok end)

    errors |> Enum.each(&log(&1))
    oks |> Enum.map(fn {:ok, result} -> result end)
  end

  defp log({type, error}) do
    Stump.log(:error, %{message: "Component Process Error", type: type, error: error})
  end
end
