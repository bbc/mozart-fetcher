defmodule MozartFetcher.CustomFormatter do
  require Logger

  def format(level, message, timestamp, metadata) do
    log_hash = %{
      level: level,
      time: Logger.Formatter.format_time(elem(timestamp, 1)),
      event: "#{message}",
    } ++ metadata
   Poison.encode!(log_hash)
  rescue
    e in _ -> e
  end
end