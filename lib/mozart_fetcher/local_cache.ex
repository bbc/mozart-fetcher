defmodule MozartFetcher.LocalCache do
  def get_or_store(id, fun) do
    ConCache.get(:fetcher_cache, id)
    |> cond_fetch(id, fun)
  end

  defp cond_fetch(nil, id, fun) do
    case fun.() do
      resp = {:ok, %HTTPoison.Response{status_code: 200}} -> store(id, resp)
      other -> other
    end
  end

  defp cond_fetch(value, _id, _fun) do
    value
  end

  defp store(id, resp) do
    ConCache.put(:fetcher_cache, id, resp)
    resp
  end
end
