defmodule MozartFetcher.Component do
  alias MozartFetcher.{Config, Envelope, LocalCache}

  def fetch({config = %Config{}, component_index}) do
    process(component_index, config, get(config))
  end

  defp process(component_index, config = %Config{format: "ares"}, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, data} ->
        metric(config.id, 200)
        %{index: component_index, id: config.id, status: 200, data: data}
      {:error, _err} ->
        metric(config.id, :json_decode_error)
        failed_component(component_index, :json_decode_error, config.id, :ares)
    end
  end

  defp process(component_index, config, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    metric(config.id, 200)
    %{index: component_index, id: config.id, status: 200, envelope: Envelope.build(body)}
  end

  defp process(component_index, config = %Config{format: "ares"}, {:ok, %HTTPoison.Response{status_code: status_code}}) do
    metric(config.id, status_code)
    %{index: component_index, id: config.id, status: status_code, data: %{}}
  end

  defp process(component_index, config, {:ok, %HTTPoison.Response{status_code: status_code}}) do
    metric(config.id, status_code)
    %{index: component_index, id: config.id, status: status_code, envelope: %Envelope{}}
  end

  defp process(component_index, config = %Config{format: "ares"}, {:error, %HTTPoison.Error{reason: reason}}) do
    metric(config.id, reason)
    failed_component(component_index, reason, config.id, :ares)
  end

  defp process(component_index, config, {:error, %HTTPoison.Error{reason: reason}}) do
    metric(config.id, reason)
    failed_component(component_index, reason, config.id, :envelope)
  end

  defp get(config) do
    LocalCache.get_or_store(config.endpoint, fn -> HTTPClient.get(config.endpoint) end)
  end

  defp failed_component(component_index, :timeout, id, :envelope) do
    %{index: component_index, id: id, status: 408, envelope: %Envelope{}}
  end

  defp failed_component(component_index, _, id, :envelope) do
    %{index: component_index, id: id, status: 500, envelope: %Envelope{}}
  end

  defp failed_component(component_index, :timeout, id, :ares) do
    %{index: component_index, id: id, status: 408, data: %{}}
  end

  defp failed_component(component_index, _, id, :ares) do
    %{index: component_index, id: id, status: 500, data: %{}}
  end

  defp metric(id, 200) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{id}.200")
  end

  defp metric(id, status) when is_integer(status) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{id}")
    ExMetrics.increment("error.component.process.#{id}.#{status}")
    ExMetrics.increment("error.component.process.#{status}")
    Stump.log(:error, %{message: "Non-200 response. Got status:#{status} for component #{id}"})
  end

  defp metric(id, reason) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{id}")
    ExMetrics.increment("error.component.process.#{reason}")
    ExMetrics.increment("error.component.process.#{id}.#{reason}")
    Stump.log(:error, %{message: "Failed to process HTTP request, reason: #{reason}, id: #{id}"})
  end
end
