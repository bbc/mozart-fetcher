defmodule MozartFetcher.FetcherTest do
  alias MozartFetcher.{Fetcher}

  use ExUnit.Case

  doctest MozartFetcher.Fetcher

  test "it returns an error id the component list is empy" do
    assert Fetcher.process([]) == {:error}
  end
end
