defmodule HTTPClient do
  use ExMetrics

  alias MozartFetcher.TimeoutParser

  def get(endpoint, client \\ client()) do
    try do
      ExMetrics.timeframe "function.timing.http_client.get" do
        headers = []

        options = [
          recv_timeout: TimeoutParser.parse(endpoint),
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
    rescue
      ex ->
        Stump.log(:error, %{message: ex})
        {:error, %HTTPoison.Error{reason: :unexpected}}
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
