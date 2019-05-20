defmodule HTTPClient do
  use ExMetrics

  @content_timeout MozartFetcher.content_timeout()

  def get(endpoint, client \\ client()) do
    ExMetrics.timeframe "function.timing.http_client.get" do
      headers = []

      options = [
        recv_timeout: timeout(endpoint),
        ssl: MozartFetcher.request_ssl(),
        hackney: [pool: :origin_pool]
      ]

      case make_request(sanitise(endpoint), headers, options, client) do
        {:error, %HTTPoison.Error{reason: :closed}} ->
          ExMetrics.increment("http.component.retry")
          make_request(sanitise(endpoint), headers, options, client)

        {k, resp} ->
          {k, resp}
      end
      |> log_errors_and_return()
    end
  end

  def timeout(endpoint) do
    URI.parse(endpoint)
    |> Map.get(:query, "")
    |> to_string
    |> URI.decode_query()
    |> Map.get("timeout", "")
    |> to_string
    |> Integer.parse()
    |> parse_timeout
  end

  defp parse_timeout({timeout, _}) when is_integer(timeout) and timeout > 0, do: timeout * 1000

  defp parse_timeout(_), do: @content_timeout

  defp sanitise(endpoint) do
    String.replace(endpoint, " ", "%20")
  end

  defp make_request(endpoint, headers, options, client) do
    client.get(endpoint, headers, options)
  end

  defp log_errors_and_return(response = {:error, %HTTPoison.Error{reason: reason}}) do
    Stump.log(:error, %{message: "HTTPoison Error", reason: reason})
    response
  end

  defp log_errors_and_return(response = {:ok, _}), do: response

  defp client() do
    HTTPoison
  end
end
