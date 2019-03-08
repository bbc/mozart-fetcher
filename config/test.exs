use Mix.Config

config :mozart_fetcher, timeout: 100
config :mozart_fetcher, time_api: MozartFetcher.Time.MockTime