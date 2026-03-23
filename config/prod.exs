import Config

config :logger, :file,
  path: "/var/log/component/app.log",
  format: {MozartFetcher.Logger.Formatter, :format},
  metadata: :all,
  level: :error
