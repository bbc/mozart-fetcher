defmodule MozartFetcher.Time.MockTime do
  @behaviour MozartFetcher.Time

  def utc_now() do
    DateTime.from_unix!(01551398400) # It's always 1st March 2019
  end
end
