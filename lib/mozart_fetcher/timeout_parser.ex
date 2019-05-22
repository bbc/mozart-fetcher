defmodule MozartFetcher.TimeoutParser do
  @default_timeout MozartFetcher.content_timeout()

  def parse(endpoint) do
    uri = URI.parse(endpoint)
    query(uri.query)
  end

  def max(components) do
    components
    |> Enum.reduce(@default_timeout, &component_timeout_or_current_timeout/2)
  end

  defp component_timeout_or_current_timeout(component, current_timeout) do
    Enum.max([parse(component.endpoint), current_timeout])
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

  defp fetch("0") do
    @default_timeout
  end

  defp fetch(qs_timeout) do
    parse_timeout(Integer.parse(qs_timeout))
  end

  defp parse_timeout({timeout, _}) when is_integer(timeout) do
    timeout * 1_000
  end

  defp parse_timeout(_) do
    @default_timeout
  end
end
