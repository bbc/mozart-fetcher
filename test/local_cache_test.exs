defmodule MozartFetcher.LocalCacheTest do
  use ExUnit.Case

  alias MozartFetcher.LocalCache

  setup do
    cache()
    |> Enum.each(fn {key, _} -> ConCache.delete(:fetcher_cache, key) end)

    :ok
  end

  describe "a successful 200 response" do
    test "store the results in cache" do
      response = {:ok, %HTTPoison.Response{status_code: 200, body: "valid response!"}}

      f = fn -> response end

      assert LocalCache.get_or_store("abc", f) == response
      assert cache() == [{"abc", response}]
    end
  end

  describe "a successful 404 response" do
    test "will NOT store the results in cache" do
      response = {:ok, %HTTPoison.Response{status_code: 404, body: "not found :()"}}
      f = fn -> response end

      assert LocalCache.get_or_store("abc", f) == response
      assert cache() == []
    end
  end

  describe "an error response" do
    test "store the results in cache" do
      response = {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}

      f = fn -> response end
      assert LocalCache.get_or_store("abc", f) == response
      assert cache() == []
    end
  end

  defp cache() do
    :fetcher_cache
    |> ConCache.ets()
    |> :ets.tab2list()
  end
end
