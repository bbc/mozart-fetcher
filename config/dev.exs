use Mix.Config

config :mozart_fetcher, timeout: 3000

config :ex_metrics,
  send_metrics: false,
  raise_on_undefined_metrics: true
