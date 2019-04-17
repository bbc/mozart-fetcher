defmodule MozartFetcher.Component do
  alias MozartFetcher.{Component, Config, Envelope, LocalCache}

  @derive [Jason.Encoder]
  defstruct [:index, :id, :status, :envelope]

  def fetch({config = %Config{}, component_index}) do
    process(component_index, config, get(config))
  end

  defp process(component_index, config, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{config.id}.200")
    %Component{index: component_index, id: config.id, status: 200, envelope: Envelope.build(body)}
  end

  defp process(component_index, config, {:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{config.id}.#{status_code}")
    Stump.log(:error, %{message: "Non-200 response. Got status:#{status_code} for component #{config.id}"})
    %Component{index: component_index, id: config.id, status: status_code, envelope: %Envelope{}}
  end

  defp process(component_index, config, {:error, %HTTPoison.Error{reason: reason}}) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{config.id}.#{reason}")
    Stump.log(:error, %{message: "Failed to process HTTP request, reason: #{reason}"})
    failed_component(component_index, reason, config.id)
  end

  defp get(config) do
    LocalCache.get_or_store(config.endpoint, fn -> HTTPClient.get(config.endpoint) end)
  end

  defp failed_component(component_index, :timeout, id) do
    %Component{index: component_index, id: id, status: 408, envelope: %Envelope{}}
  end

  defp failed_component(component_index, _, id) do
    %Component{index: component_index, id: id, status: 500, envelope: %Envelope{}}
  end
end
