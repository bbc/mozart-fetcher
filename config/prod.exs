use Mix.Config

config :ex_metrics,
  send_metrics: true,
  raise_on_undefined_metrics: false

config :logger,
  backends: [{LoggerFileBackend, :file}]

config :logger, :file,
  path: "/var/log/component/app.log",
  format: "$message\n",
  level: :error
