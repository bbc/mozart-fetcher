defmodule MozartFetcher.Router do
  alias MozartFetcher.{Fetcher, Config, Decoder}

  use Plug.Router
  use ExMetrics
  plug(Plug.Head)
  plug(ExMetrics.Plug.PageMetrics)

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

  def send_response({:error, exception}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(exception.status, exception.message)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def config(body) do
    case Decoder.decode_config(body, %Config{}) do
      {:ok, components} ->
        ExMetrics.increment("success.components.decode")
        {:ok, components}

      {:error} ->
        ExMetrics.increment("error.components.decode")
        Stump.log(:error, %{message: "Failed to decode components into list"})
        {:error, %{message: "Internal Server Error", status: 500}}
    end
  end
end
