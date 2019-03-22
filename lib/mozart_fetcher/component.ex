defmodule MozartFetcher.Component do
  alias MozartFetcher.{Component, Config, Envelope, LocalCache}

  @derive [Poison.Encoder]
  defstruct [:index, :id, :status, :envelope]

  def fetch(config = %Config{}) do
    process(config, get(config))
  end

  defp process(config, {:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{config.id}.#{status_code}")
    %Component{index: 0, id: config.id, status: status_code, envelope: Envelope.build(body)}
  end

  defp process(config, {:error, %HTTPoison.Error{reason: reason}}) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{config.id}.#{reason}")
    Stump.log(:error, %{message: "Failed to process HTTP request, reason: #{reason}"})
    {:error, reason}
  end

  defp get(config) do
    LocalCache.get_or_store(config.endpoint, fn -> HTTPClient.get(config.endpoint) end)
  end
end
