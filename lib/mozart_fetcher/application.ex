defmodule MozartFetcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: MozartFetcher.Worker.start_link(arg)
      # {Fetcher.Worker, arg},
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: MozartFetcher.Router,
        options: [port: 8080]
      ),
      {ConCache, [name: :fetcher_cache, ttl_check_interval: :timer.seconds(1), global_ttl: :timer.seconds(30)]}
    ]

    Application.put_env(:mozart_fetcher, :dev_cert_pem, System.get_env("DEV_CERT_PEM"))

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MozartFetcher.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
