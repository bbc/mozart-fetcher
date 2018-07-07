defmodule Fetcher.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  get "/status" do
    send_resp(conn, 200, "OK")
  end

  post "/collect" do
    {:ok, body, conn} = read_body(conn)
    body = decode(body)
    resp = Fetcher.Fetcher.process(body["components"])

    send_resp(conn, 200, resp)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def decode(body) do
    Poison.decode!(body, as: %{"components" => [%Component{}]})
  end
end
