use Mix.Config

config :logger, level: :warn

config :mozart_fetcher,
  content_timeout: 100,
  connection_timeout: 20

config :ex_metrics,
  send_metrics: false,
  raise_on_undefined_metrics: true
