defmodule MozartFetcher.LocalCache do
  def get_or_store(id, f) do
    case Mix.env do
      :test -> f.()
      _ -> ConCache.get_or_store(:fetcher_cache, id, f)
    end
  end
end
