defmodule MozartFetcher.Router do
  require Logger
  alias MozartFetcher.{Fetcher, Config, Decoder}

  use Plug.Router
  plug(Plug.Head)
  plug(MozartFetcher.Plug.PageMetrics)

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
        :telemetry.execute([:success, :components, :decode], %{})
        {:ok, components}

      {:error} ->
        :telemetry.execute([:error, :components, :decode], %{})
        Logger.error("Failed to decode components into list")
        {:error, %{message: "Internal Server Error", status: 500}}
    end
  end
end
