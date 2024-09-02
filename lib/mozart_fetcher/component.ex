defmodule MozartFetcher.Component do
  require Logger
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
    headers = config.headers || %{}

    LocalCache.get_or_store(config.endpoint, fn ->
      HTTPClient.get(config.endpoint, Map.to_list(headers))
    end)
  end

  defp failed_component(component_index, :timeout, id) do
    %{index: component_index, id: id, status: 408, envelope: %Envelope{}}
  end

  defp failed_component(component_index, _, id) do
    %{index: component_index, id: id, status: 500, envelope: %Envelope{}}
  end

  defp metric(id, _endpoint, 200) do
    :telemetry.execute([:success, :component, :process], %{}, %{
      status_code: 200,
      component_id: id
    })
  end

  defp metric(id, endpoint, status) when is_integer(status) do
    :telemetry.execute([:error, :component, :process], %{}, %{
      status_code: status,
      component_id: id
    })

    Logger.error("Non-200 response", %{
      status: status,
      component: id,
      endpoint: endpoint
    })
  end

  defp metric(id, endpoint, reason) do
    :telemetry.execute([:error, :component, :process], %{}, %{component_id: id})

    Logger.error("Failed to process HTTP request", %{
      reason: reason,
      id: id,
      endpoint: endpoint
    })
  end
end
