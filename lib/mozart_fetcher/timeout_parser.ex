defmodule MozartFetcher.TimeoutParser do
  @default_timeout MozartFetcher.content_timeout()

  def parse(endpoint) do
    uri = URI.parse(endpoint)
    query(uri.query)
  end

  defp query(nil) do
    @default_timeout
  end

  defp query(q) do
    qs = URI.decode_query(q)
    fetch(qs["timeout"])
  end

  defp fetch(nil) do
    @default_timeout
  end

  defp fetch(qs_timeout) do
    String.to_integer(qs_timeout) * 1_000
  end
end
