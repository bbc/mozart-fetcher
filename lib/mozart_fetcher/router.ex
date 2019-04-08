defmodule MozartFetcher.Router do
  alias MozartFetcher.{Fetcher, Config, Decoder}

  use Plug.Router
  use ExMetrics
  plug(ExMetrics.Plug.PageMetrics)

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
    send_response(config(body), conn)
  end

  def send_response({:ok, components}, conn) do
    response = Fetcher.process(components)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end

  def send_response(:error, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, "Internal Server Error")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def config(body) do
    case Decoder.list_to_struct_list(body, %Config{}) do
      {:ok, components} ->
        ExMetrics.increment("success.components.decode")
        {:ok, components}
      {:error}        ->
        ExMetrics.increment("error.components.decode")
        Stump.log(:error, %{message: "Failed to decode components into list", body: body})
        {:error}
    end
  end
end
