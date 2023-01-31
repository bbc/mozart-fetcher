use Mix.Config

config :statix,
  tags: ["BBCEnvironment:#{System.get_env("PRODUCTION_ENVIRONMENT")}"]