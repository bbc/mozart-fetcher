defmodule MozartFetcher.Time.DateTime do
  @behaviour MozartFetcher.Time

  def utc_now() do
    DateTime.utc_now()
  end
end
