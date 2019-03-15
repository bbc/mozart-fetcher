use Mix.Config

config :logger, level: :warn

config :mozart_fetcher, timeout: 100

config :ex_metrics,
  send_metrics: false,
  raise_on_undefined_metrics: true
