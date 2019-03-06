defmodule HTTPClient do
  use ExMetrics

  def get(endpoint) do
    ExMetrics.timeframe "function.timing.http_client.get" do
      cert = Application.get_env(:mozart_fetcher, :dev_cert_pem)
      timeout = Application.get_env(:mozart_fetcher, :timeout)

      headers = []
      options = [recv_timeout: timeout, ssl: [certfile: cert]]

      HTTPoison.get(endpoint, headers, options)
    end
  end
end
