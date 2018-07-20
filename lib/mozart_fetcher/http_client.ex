defmodule HTTPClient do
  @cert System.get_env("DEV_CERT_PEM")

  def get(endpoint) do
    headers = []
    options = [recv_timeout: 3000, ssl: [certfile: @cert]]

    HTTPoison.get(endpoint, headers, options)
  end
end
