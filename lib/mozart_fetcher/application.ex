defmodule MozartFetcher.Application do
  @moduledoc false
  require Logger

  use Application
  alias MozartFetcher.Metrics

  @connection_timeout MozartFetcher.connection_timeout()
  @max_connections MozartFetcher.max_connections()

  defp children(env: :test) do
    [
      Metrics.TelemetrySupervisor,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: MozartFetcher.FakeOrigin,
        options: [port: 8082]
      )
    ]
  end

  defp children(_) do
    [
      Metrics.TelemetrySupervisor,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: MozartFetcher.Router,
        options: [port: 8080]
      )
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
end
