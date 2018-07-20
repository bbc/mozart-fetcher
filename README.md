# Fetcher

The service provides a single /collect endpoint which expects a JSON payload in the format:

```json
{
    "components": [{
        "id": "stream-icons",
        "endpoint": "https://s3-eu-west-1.amazonaws.com/shared-application-buckets-public-1pmfwo80l61it/load-tests/static_envelopes/25082016/small-1.0.4.json",
        "must_succeed": true
    }]
}
```

The component endpoint will return:

```json
{
  "head": [],
  "bodyInline": "<DIV id=\"site-container\" role=\"main\">",
  "bodyLast": []
}
```


Requester returns a JSON collection of components in this format:

```json
{
    "components": [{
        "Index": "<index>",
        "id": "<component_id>",
        "Status": "<component_status>",
        "envelope": {
            "head": [],
            "bodyInline": "",
            "bodyLast": []
        }
    }]
}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fetcher` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fetcher, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fetcher](https://hexdocs.pm/fetcher).


## Run locally

```sh
# get dependencies
mix deps.get

# compile project
mix compile

# run the project
mix run --no-halt

# run the project interactive mode
iex -S mix
```

## Local endpoints

```sh
curl localhost:8080/status

curl -X POST --data '{"components":[{"id":"stream-icons","endpoint":"https://s3-eu-west-1.amazonaws.com/shared-application-buckets-public-1pmfwo80l61it/load-tests/static_envelopes/25082016/small-1.0.4.json","must_succeed":true}]}' localhost:8080/collect

curl -X POST --data @test/fixtures/payload_multiple_small.json localhost:8080/collect
```

## Run tests

```sh
mix test
```
