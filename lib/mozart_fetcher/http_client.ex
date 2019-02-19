defmodule HTTPClient do
  def get(endpoint) do
    cert = Application.get_env(:mozart_fetcher, :dev_cert_pem)
    headers = []
    options = [recv_timeout: 3000, ssl: [certfile: cert]]

    IO.puts 'Fetching from HTTP'
    HTTPoison.get(endpoint, headers, options)
  end
end
