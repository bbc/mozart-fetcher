defmodule MozartFetcher.Component do
  alias MozartFetcher.{Components, Components.Ares, Config, Envelope, LocalCache}

  def fetch({config = %Config{}, component_index}) do
    process(component_index, config, get(config))
  end

  #todo refactor and handle decoding errors, add more tests for invalid json.
  defp process(component_index, config = %Config{format: "ares"}, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{config.id}.200")
    %Components.Ares{index: component_index, id: config.id, status: 200, data: Jason.decode!(body, keys: :atoms)}
  end

  defp process(component_index, config, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{config.id}.200")
    %Components.Envelope{index: component_index, id: config.id, status: 200, envelope: Envelope.build(body)}
  end

  defp process(component_index, config = %Config{format: "ares"}, {:ok, %HTTPoison.Response{status_code: status_code, body: _body}}) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{config.id}.#{status_code}")
    Stump.log(:error, %{message: "Non-200 response. Got status:#{status_code} for component #{config.id}"})
    %Components.Ares{index: component_index, id: config.id, status: status_code, data: %{}}
  end

  defp process(component_index, config, {:ok, %HTTPoison.Response{status_code: status_code, body: _body}}) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{config.id}.#{status_code}")
    Stump.log(:error, %{message: "Non-200 response. Got status:#{status_code} for component #{config.id}"})
    %Components.Envelope{index: component_index, id: config.id, status: status_code, envelope: %Envelope{}}
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
    %Components.Envelope{index: component_index, id: id, status: 408, envelope: %Envelope{}}
  end

  defp failed_component(component_index, _, id) do
    %Components.Envelope{index: component_index, id: id, status: 500, envelope: %Envelope{}}
  end
end
