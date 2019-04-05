defmodule MozartFetcher.Component do
  alias MozartFetcher.{Component, Config, Envelope, LocalCache}

  @derive [Poison.Encoder]
  defstruct [:index, :id, :status, :envelope]

  def fetch(config = %Config{}) do
    process(config, get(config))
  end

  defp process(config, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    ExMetrics.increment("success.component.process")
    ExMetrics.increment("success.component.process.#{config.id}.200")
    %Component{index: 0, id: config.id, status: 200, envelope: Envelope.build(body)}
  end

  defp process(config, {:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    ExMetrics.increment("error.component.process")
    ExMetrics.increment("error.component.process.#{config.id}.#{status_code}")
    Stump.log(:error, %{message: "Non-200 response. Got status:#{status_code} for component #{config.id}"})
    %Component{index: 0, id: config.id, status: status_code, envelope: %Envelope{}}
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
