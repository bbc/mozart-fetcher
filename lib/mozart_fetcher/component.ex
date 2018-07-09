defmodule MozartFetcher.Component do
  alias MozartFetcher.{Component, Config}

  #@derive [Poison.Encoder]
  defstruct [:endpoint, :id, :must_succed]

  def fetch(config = %Config{}) do
    case HTTPClient.get(config.endpoint) do
      {:ok,    %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:error, %HTTPoison.Error{reason: :timeout}}                -> {:error, :timeout}
      {:error, %HTTPoison.Error{reason: reason}}                  -> {:error, reason}
    end
  end
end
