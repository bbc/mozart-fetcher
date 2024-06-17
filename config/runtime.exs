import Config

if System.get_env("RELEASE_MODE") do
  [
    {"PRODUCTION_ENVIRONMENT", :default}
  ]
  |> Enum.each(fn {config_key, set_type} ->
    if System.get_env(config_key) == nil do
      raise "Config not set in environment: #{config_key}"
    end

    if set_type == :default do
      config :mozart_fetcher,
             Keyword.new([
               {String.to_atom(String.downcase(config_key)), System.get_env(config_key)}
             ])
    end
  end)
end
