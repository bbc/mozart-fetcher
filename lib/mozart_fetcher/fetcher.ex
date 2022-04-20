defmodule MozartFetcher.Fetcher do
  require Logger
  alias MozartFetcher.{Component, TimeoutParser, Envelope}

  use ExMetrics

  @timeout_buffer 50
  @max_concurrency 50

  def process([]) do
    ExMetrics.increment("error.empty_component_list")
    Logger.error("Error cannot process empty component list")
    {:error}
  end

  def process(configs, buffer \\ @timeout_buffer) do
    ExMetrics.timeframe "function.timing.fetcher.process" do
      max_timeout = TimeoutParser.max(configs) + buffer

      stream_opts = [
        timeout: max_timeout,
        on_timeout: :kill_task,
        max_concurrency: @max_concurrency
      ]

      configs
      |> Enum.with_index()
      |> Task.async_stream(&Component.fetch/1, stream_opts)
      |> zip(configs)
      |> decorate_response()
      |> Jason.encode!()
    end
  end

  defp decorate_response(envelopes) do
    %{components: envelopes}
  end

  defp zip(responses, configs) do
    for {response, config} <- Enum.zip(responses, configs) do
      handle(response, config.id)
    end
  end

  defp handle({:ok, result}, _id), do: result

  defp handle({state, reason}, id) do
    Logger.error("Component Process Error", state: state, reason: reason, id: id)

    status = if reason == :timeout, do: 408, else: 500
    %{envelope: %Envelope{}, id: id, index: nil, status: status}
  end
end
