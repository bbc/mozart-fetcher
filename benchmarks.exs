alias MozartFetcher.{Fetcher, Config}
{:ok, file} = File.read("components.json")
body = Poison.decode!(file, as: %{"components" => [%Config{}]})

Benchee.run(%{
  "components" => fn -> MozartFetcher.Fetcher.process(body["components"]) end
}, [time: 30, parallel: 4] )