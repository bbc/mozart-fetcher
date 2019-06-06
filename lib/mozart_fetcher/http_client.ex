defmodule HTTPClient do
  use ExMetrics

  alias MozartFetcher.TimeoutParser

  def get(endpoint, client \\ client()) do
    try do
      ExMetrics.timeframe "function.timing.http_client.get" do
        headers = [{"accept-encoding", "gzip"}]

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
            handle_response({k, resp})
        end
        |> log_errors_and_return()
      end
    rescue
      _ ->
        ExMetrics.increment("http.component.error")
        Stump.log(:error, %{message: "HTTP Client error caught"})
        {:error, %HTTPoison.Error{reason: :unexpected}}
    end
  end

  defp sanitise(endpoint) do
    String.replace(endpoint, " ", "%20")
  end

  defp make_request(endpoint, headers, options, client) do
    client.get(endpoint, headers, options)
  end

  defp handle_response({:ok, response}) do
    {:ok,
     Map.put(
       response,
       :body,
       decode_response_body(response.body, content_encoding(process_headers(response.headers)))
     )}
  end

  defp handle_response(response), do: response

  defp process_headers(headers) do
    Enum.map(headers, fn {k, v} -> {String.downcase(k), v} end)
  end

  defp decode_response_body(body, "gzip"), do: :zlib.gunzip(body)
  defp decode_response_body(body, "x-gzip"), do: :zlib.gunzip(body)
  defp decode_response_body(body, _encoding), do: body

  defp content_encoding(headers) do
    case get_content_encoding(headers) do
      {_, content_encoding} ->
        content_encoding

      nil ->
        ""
    end
  end

  defp get_content_encoding(headers) do
    List.keyfind(headers, "content-encoding", 0)
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
