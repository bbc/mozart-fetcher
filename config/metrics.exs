use Mix.Config

config :ex_metrics,
  metrics: [
    "function.timing.http_client.get",
    "function.timing.fetcher.process",
    "success.envelope.decode",
    "error.envelope.decode",
    "success.component.process",
    "error.empty_component_list",
    "error.component.process"
  ]
