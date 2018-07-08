defmodule MozartFetcher.Component do
  alias MozartFetcher.{Component}

  @derive [Poison.Encoder]
  defstruct [:endpoint, :id, :must_succed]

  def fetch(component = %Component{}) do
    case HTTPClient.get(component.endpoint) do
      {:ok,    %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:error, %HTTPoison.Error{reason: :timeout}}                -> {:error, :timeout}
      {:error, %HTTPoison.Error{reason: reason}}                  -> {:error, reason}
    end
  end
end
