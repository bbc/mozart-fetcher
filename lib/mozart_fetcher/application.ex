defmodule MozartFetcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @connection_timeout Application.get_env(:mozart_fetcher, :connection_timeout)
  @max_connections Application.get_env(:mozart_fetcher, :max_connections)

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
         global_ttl: :timer.seconds(30)
       ]}
    ]
  end

  def start(_type, args) do
    # List all child processes to be supervised
    children = children(args)

    Application.put_env(:mozart_fetcher, :dev_cert_pem, System.get_env("DEV_CERT_PEM"))

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
end
