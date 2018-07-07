defmodule FetcherTest do
  use ExUnit.Case
  doctest Fetcher

  test "greets the world" do
    assert Fetcher.hello() == :world
  end
end
