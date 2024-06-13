import Config

config :logger, level: :warning

config :mozart_fetcher,
  default_content_timeout: 500,
  default_connection_timeout: 50
