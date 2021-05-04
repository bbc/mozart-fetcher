defmodule MozartFetcher.Component do
  alias MozartFetcher.{Config, Envelope, LocalCache}

  def fetch({config = %Config{}, component_index}) do
    process(component_index, config, get(config))
  end

  defp process(
         component_index,
         config = %Config{endpoint: endpoint},
         {:ok, %HTTPoison.Response{status_code: 200, body: body}}
       ) do
    metric(config.id, endpoint, 200)
    %{index: component_index, id: config.id, status: 200, envelope: Envelope.build(body)}
  end

  defp process(
         component_index,
         config = %Config{endpoint: endpoint},
         {:ok, %HTTPoison.Response{status_code: status_code}}
       ) do
    metric(config.id, endpoint, status_code)
    %{index: component_index, id: config.id, status: status_code, envelope: %Envelope{}}
  end

  defp process(
         component_index,
         config = %Config{endpoint: endpoint},
         {:error, %HTTPoison.Error{reason: reason}}
       ) do
    metric(config.id, endpoint, reason)
    failed_component(component_index, reason, config.id)
  end

  defp get(config) do
    LocalCache.get_or_store(config.endpoint, fn -> HTTPClient.get(config.endpoint) end)
  end

  defp failed_component(component_index, :timeout, id) do
    %{index: component_index, id: id, status: 408, envelope: %Envelope{}}
  end

  defp failed_component(component_index, _, id) do
    %{index: component_index, id: id, status: 500, envelope: %Envelope{}}
  end

  defp metric(id, _endpoint, 200) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{id}.200")
  end

  defp metric(id, endpoint, status) when is_integer(status) do
    ExMetrics.increment("error.component.process.#{id}")
    ExMetrics.increment("error.component.process.#{id}.#{status}")
    ExMetrics.increment("error.component.process.#{status}")

    Stump.log(:error, %{
      message: "Non-200 response",
      status: status,
      component: id,
      endpoint: endpoint
    })
  end

  defp metric(id, endpoint, reason) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{id}")

    Stump.log(:error, %{
      message: "Failed to process HTTP request",
      reason: reason,
      id: id,
      endpoint: endpoint
    })
  end
end
