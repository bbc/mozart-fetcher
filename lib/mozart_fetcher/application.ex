defmodule MozartFetcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @connection_timeout MozartFetcher.connection_timeout()
  @max_connections MozartFetcher.max_connections()

  defp children(env: :test) do
    children(env: :prod) ++
      [
        Plug.Cowboy.child_spec(
          scheme: :http,
          plug: MozartFetcher.FakeOrigin,
          options: [port: 8082]
        )
      ]
  end

  defp children(_) do
    [
      # Starts a worker by calling: MozartFetcher.Worker.start_link(arg)
      # {Fetcher.Worker, arg},
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
    # List all child processes to be supervised
    children = children(args)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
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
      Stump.log(:error, %{
        message: "Invalid TTL Value, you must provide an integer value for the tll",
        ttl: ttl
      })

      10
  end
end
