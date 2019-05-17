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

      case make_request(sanitise(endpoint), headers, options) do
        {:error, %HTTPoison.Error{reason: "closed"}} ->
          handle_response(make_request(sanitise(endpoint), headers, options))
        {k, response} -> handle_response({k, response})
      end
    end
  end

  defp handle_response(response = {:error, %HTTPoison.Error{reason: reason}}) do
    Stump.log(:error, %{message: "HTTPoison Error", reason: reason})
    response
  end

  defp handle_response(response), do: response

  defp sanitise(endpoint) do
    String.replace(endpoint, " ", "%20")
  end

  defp make_request(endpoint, headers, options) do
    HTTPoison.get(endpoint, headers, options)
  end
end
