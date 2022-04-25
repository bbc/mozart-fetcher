defmodule MozartFetcher.Application do
  @moduledoc false
  require Logger

  use Application

  @connection_timeout MozartFetcher.connection_timeout()
  @max_connections MozartFetcher.max_connections()

  defp children(env: :test) do
    [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: MozartFetcher.FakeOrigin,
        options: [port: 8082]
      ),
      {ConCache, [name: :fetcher_cache, ttl_check_interval: false]}
    ]
  end

  defp children(_) do
    [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: MozartFetcher.Router,
        options: [port: 8080]
      ),
      {ConCache,
       [
         name: :fetcher_cache,
         ttl_check_interval: :timer.seconds(1),
         global_ttl: :timer.seconds(to_ttl(System.get_env("local_cache_ttl")))
       ]}
    ]
  end

  def start(_type, args) do
    children = children(args)

    opts = [strategy: :one_for_one, name: MozartFetcher.Supervisor]
    Supervisor.start_link(children ++ hackney_setup(), opts)
  end

  defp hackney_setup do
    [
      :hackney_pool.child_spec(:origin_pool,
        timeout: @connection_timeout,
        max_connections: @max_connections
      )
    ]
  end

  defp to_ttl(ttl) when is_integer(ttl), do: ttl

  defp to_ttl(ttl) do
    String.to_integer(ttl)
  rescue
    ArgumentError ->
      Logger.error("Invalid TTL Value, you must provide an integer value for the tll", %{
        ttl: ttl
      })

      10
  end
end
