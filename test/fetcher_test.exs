defmodule MozartFetcher.FetcherTest do
  alias MozartFetcher.{Fetcher, Config}

  use ExUnit.Case

  doctest MozartFetcher.Fetcher

  test "it returns an error id the component list is empy" do
    assert Fetcher.process([]) == {:error}
  end

  test "it gets success when passing component config" do
    assert Fetcher.process([%Config{endpoint: "http://localhost:8082/foo", id: "foo"}]) ==
             "{\"components\":[{\"envelope\":{\"bodyInline\":\"\",\"bodyLast\":[],\"head\":[]},\"id\":\"foo\",\"index\":0,\"status\":200}]}"
  end

  test "it returns the components which don't exceed max async fetch timeout" do
    config = [
      %Config{endpoint: "http://localhost:8082/foo", id: "foo"},
      %Config{endpoint: "http://localhost:8082/timeout", id: "timeout"}
    ]

    expected =
      "{\"components\":[{\"envelope\":{\"bodyInline\":\"\",\"bodyLast\":[],\"head\":[]},\"id\":\"foo\",\"index\":0,\"status\":200}]}"

    assert Fetcher.process(config) == expected
  end
end
