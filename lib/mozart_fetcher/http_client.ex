defmodule HTTPClient do
  use ExMetrics

  @content_timeout MozartFetcher.content_timeout()

  def get(endpoint, client \\ client()) do
    ExMetrics.timeframe "function.timing.http_client.get" do
      headers = []

      options = [
        recv_timeout: @content_timeout,
        ssl: MozartFetcher.request_ssl(),
        hackney: [pool: :origin_pool]
      ]

      case make_request(sanitise(endpoint), headers, options, client) do
        {:error, %HTTPoison.Error{reason: :closed}} ->
          make_request(sanitise(endpoint), headers, options, client)

        {k, resp} ->
          {k, resp}
      end
      |> log_errors_and_return()
    end
  end

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
