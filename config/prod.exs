use Mix.Config

config :logger, level: :error

config :mozart_fetcher, timeout: 3000

config :ex_metrics,
  send_metrics: true,
  raise_on_undefined_metrics: false
