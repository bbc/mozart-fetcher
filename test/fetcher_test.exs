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
end
