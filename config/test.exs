use Mix.Config

config :logger, level: :warn

config :mozart_fetcher,
  default_content_timeout: 500,
  default_connection_timeout: 50

config :ex_metrics,
  send_metrics: false,
  raise_on_undefined_metrics: true
