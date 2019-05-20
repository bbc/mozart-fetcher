defmodule MozartFetcher.LocalCache do
  def get_or_store(id, f) do
    case f.() do
      {:ok, resp} -> ConCache.get_or_store(:fetcher_cache, id, fn() -> {:ok, resp} end)
      {:error, resp} -> {:error, resp}
    end
  end
end
