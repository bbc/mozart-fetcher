use Mix.Config

if System.get_env("DEV_CERT_PEM") == nil do
  raise "Your developer certificate is not set correctly please ensure you set it to the environment variable $DEV_CERT_PEM"
end

config :mozart_fetcher,
        Keyword.new([{String.to_atom(String.downcase("DEV_CERT_PEM")), System.get_env("DEV_CERT_PEM")}])