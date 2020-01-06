use Mix.Config

cert = System.get_env("DEV_CERT_PEM")

if cert == nil do
  raise "Your developer certificate is not set correctly please ensure you set it to the environment variable $DEV_CERT_PEM"
end

if File.exists?(cert) == false do
  raise "The DEV_CERT_PEM environment variable is set, however the file path is incorrect"
end

config :mozart_fetcher,
        Keyword.new([{String.to_atom(String.downcase("DEV_CERT_PEM")), System.get_env("DEV_CERT_PEM")}])