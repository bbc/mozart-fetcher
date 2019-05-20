defmodule MozartFetcher.LocalCacheTest do
  use ExUnit.Case

  alias MozartFetcher.LocalCache
  setup do
    cache()
    |> Enum.each(fn({key, _}) -> ConCache.delete(:fetcher_cache, key) end)
    :ok
  end

  describe "a successful response" do
    test "store the results in cache" do
      f = fn () -> {:ok, "valid response"} end
      LocalCache.get_or_store("abc", f)
      assert cache() == [{"abc", {:ok, "valid response"}}]
    end
  end

  describe "an error response" do
    test "store the results in cache" do
      f = fn () -> {:error, "NOT valid response"} end
      LocalCache.get_or_store("abc", f)
      assert cache() == []
    end
  end

  defp cache() do
    :fetcher_cache
    |> ConCache.ets
    |> :ets.tab2list
  end
end
