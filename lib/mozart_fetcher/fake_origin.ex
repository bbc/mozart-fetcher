defmodule MozartFetcher.FakeOrigin do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/success" do
    send_resp(
      conn,
      200,
      ~s({"head":[],"bodyInline":"<DIV id=\\"site-container\\">","bodyLast":[]})
    )
  end

  get "/json_data" do
    send_resp(
      conn,
      200,
      ~s({"content":{"some": "json data"}})
    )
  end

  get "/big_component" do
    send_resp(
      conn,
      200,
      ~s({"head":[], "bodyInline":"<DIV id=\\"big-component\\" class=\\"big\\"><h1>This is a really big component</h1></DIV>", "bodyLast": []})
    )
  end

  get "/non_200_status/:code" do
    {status_code, _} = Integer.parse(conn.path_params["code"])
    send_resp(
      conn,
      status_code,
      ""
    )
  end

  get "/timeout" do
    :timer.sleep(3100)
  end
end
