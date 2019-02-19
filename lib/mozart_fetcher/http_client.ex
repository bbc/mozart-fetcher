defmodule HTTPClient do
  def get(endpoint) do
    cert = Application.get_env(:mozart_fetcher, :dev_cert_pem)
    timeout = Application.get_env(:mozart_fetcher, :timeout)

    headers = []
    options = [recv_timeout: timeout, ssl: [certfile: cert]]

    HTTPoison.get(endpoint, headers, options)
  end
end
