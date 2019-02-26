defmodule MozartFetcher.Router do
  alias MozartFetcher.{Fetcher, Config}

  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  get "/status" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
  end

  post "/collect" do
    {:ok, body, conn} = read_body(conn)
    body = decode(body)
    resp = Fetcher.process(body["components"])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, resp)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def decode(body) do
    Poison.decode!(body, as: %{"components" => [%Config{}]})
  end
end
