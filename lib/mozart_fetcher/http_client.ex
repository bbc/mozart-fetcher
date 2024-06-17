defmodule HTTPClient do
  require Logger

  alias MozartFetcher.TimeoutParser

  def get(endpoint, client \\ client()) do
    try do
      before_time = System.monotonic_time(:millisecond)
      headers = set_request_headers(endpoint)

      options = [
        recv_timeout: TimeoutParser.parse(endpoint),
        ssl: MozartFetcher.request_ssl(),
        hackney: [pool: :origin_pool]
      ]

      response =
        case make_request(sanitise(endpoint), headers, options, client) do
          {:error, %HTTPoison.Error{reason: :closed}} ->
            :telemetry.execute([:http, :component, :retry], %{})
            make_request(sanitise(endpoint), headers, options, client)

          {k, resp} ->
            handle_response({k, resp})
        end
        |> log_errors_and_return()

      timing = (System.monotonic_time(:millisecond) - before_time) |> abs
      :telemetry.execute([:function, :timing, :http_client, :get], %{duration: timing})
      response
    rescue
      _ ->
        :telemetry.execute([:http, :component, :error], %{})
        Logger.error("HTTP Client error caught")
        {:error, %HTTPoison.Error{reason: :unexpected}}
    end
  end

  defp set_request_headers("https://fabl.api." <> _),
    do: [{"accept-encoding", "gzip"}, {"ctx-unwrapped", "1"}]

  defp set_request_headers(_endpoint), do: [{"accept-encoding", "gzip"}]

  defp sanitise(endpoint) do
    String.replace(endpoint, " ", "%20")
  end

  defp make_request(endpoint, headers, options, client) do
    client.get(endpoint, request_headers(headers), options)
  end

  defp request_headers(headers) do
    headers ++ [{"User-Agent", "MozartFetcher"}]
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
    Logger.error("HTTPoison Error", reason: reason)
    response
  end

  defp log_errors_and_return(response = {:ok, _}),
    do: response

  defp client() do
    HTTPoison
  end
end
