defmodule MozartFetcher do
  @moduledoc """
  Documentation for Fetcher.
  """

  def content_timeout do
    case System.get_env("content_timeout") do
      nil -> Application.get_env(:mozart_fetcher, :default_content_timeout)
      content_timeout -> parse_integer(content_timeout)
    end
  end

  def connection_timeout do
    case System.get_env("connection_timeout") do
      nil -> Application.get_env(:mozart_fetcher, :default_connection_timeout)
      connection_timeout -> parse_integer(connection_timeout)
    end
  end

  def max_connections do
    Application.get_env(:mozart_fetcher, :max_connections)
  end

  def request_ssl do
    case environment() do
      :prod -> [certfile: cert_path(), keyfile: key_file_path()]
      _ -> [certfile: System.get_env("DEV_CERT_PEM")]
    end
  end

  defp cert_path do
    System.get_env("cert_file_path")
  end

  defp key_file_path do
    System.get_env("key_file_path")
  end

  def environment do
    Application.get_env(:mozart_fetcher, :environment)
  end

  defp parse_integer(value) when is_binary(value) do
    {integer, _remainder} = Integer.parse(value)
    integer
  end

  defp parse_integer(value) when is_integer(value) do
    value
  end
end
