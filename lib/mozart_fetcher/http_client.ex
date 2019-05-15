defmodule HTTPClient do
  use ExMetrics

  @content_timeout MozartFetcher.content_timeout()

  def get(endpoint) do
    ExMetrics.timeframe "function.timing.http_client.get" do
      headers = []

      options = [
        recv_timeout: @content_timeout,
        ssl: MozartFetcher.request_ssl(),
        hackney: [pool: :origin_pool]
      ]

      valid_response?(HTTPoison.get(sanitise(endpoint), headers, options))
    end
  end

  defp valid_response?(response = {:error, %HTTPoison.Error{reason: reason}}) do
    Stump.log(:error, %{message: "HTTPoison Error", reason: reason})
    response
  end

  defp valid_response?(response), do: response

  defp sanitise(endpoint) do
    String.replace(endpoint, " ", "%20")
  end
end
