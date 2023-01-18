use Mix.Config

[
  "PRODUCTION_ENVIRONMENT"
]
|> Enum.each(fn config_key ->
  if System.get_env(config_key) == nil do
    raise "Config not set in environment: #{config_key}"
  end
  config :belfrage_ccp,
         Keyword.new([{String.to_atom(String.downcase(config_key)), System.get_env(config_key)}])
end)

config :statix,
  tags: ["BBCEnvironment:#{System.get_env("PRODUCTION_ENVIRONMENT")}"]