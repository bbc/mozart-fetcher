defmodule HTTPClient do
  use ExMetrics

  @content_timeout Application.get_env(:mozart_fetcher, :content_timeout)

  def get(endpoint) do
    ExMetrics.timeframe "function.timing.http_client.get" do
      cert = Application.get_env(:mozart_fetcher, :dev_cert_pem)

      headers = []

      options = [
        recv_timeout: @content_timeout,
        ssl: [certfile: cert],
        hackney: [pool: :origin_pool]
      ]

      valid_response?(HTTPoison.get(endpoint, headers, options))
    end
  end

  defp valid_response?(response = {:error, %HTTPoison.Error{reason: reason}}) do
    Stump.log(:error, %{message: "HTTPoison Error", reason: reason})
    response
  end

  defp valid_response?(response), do: response
end
