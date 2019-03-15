defmodule MozartFetcher.FakeOrigin do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Poison
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

  get "/timeout" do
    :timer.sleep(3100)
  end
end
