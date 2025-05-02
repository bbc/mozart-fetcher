defmodule MozartFetcher.RouterTest do
  use ExUnit.Case

  import Plug.Test
  import Plug.Conn

  alias MozartFetcher.{Router}

  @opts Router.init([])

  describe "/status" do
    test "GET will return 'OK'" do
      conn = conn(:get, "/status")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["text/plain; charset=utf-8"]
      assert conn.resp_body == "OK"
    end

    test "HEAD will return 200" do
      conn = conn(:head, "/status")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["text/plain; charset=utf-8"]
    end
  end

  describe "/wrong-endpoint" do
    test "it will return a 404" do
      conn = conn(:get, "/wrong-endpoint")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "not found"
    end
  end

  # for now it performs a real HTTP request..
  describe "/collect" do
    test "it will return a JSON response containing from the origin" do
      json_body = ~s({
        "components": [{
                        "id": "stream-icons",
                        "endpoint": "localhost:8082/success",
                        "must_succeed": true
                        }]
                      }
                    )
      conn = conn(:post, "/collect", json_body)
      conn = Router.call(conn, @opts)

      expected_body =
        Jason.encode!(%{
          components: [
            %{
              status: 200,
              index: 0,
              id: "stream-icons",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline: "<DIV id=\"site-container\">"
              }
            }
          ]
        })

      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
      assert conn.resp_body == expected_body
    end
  end
end
