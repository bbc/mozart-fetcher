defmodule MozartFetcher.Fetcher do
  alias MozartFetcher.{Component, TimeoutParser, Envelope}

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
      |> validate()
      |> decorate_response()
      |> Jason.encode!()
    end
  end

  defp decorate_response(envelopes) do
    %{components: envelopes}
  end

  defp validate(responses) do
    Enum.map(responses, &handle/1)
  end

  defp handle({:ok, result}), do: result

  defp handle({state, reason}) do
    Stump.log(:error, %{message: "Component Process Error", state: state, reason: reason})
    %Envelope{}
  end
end
