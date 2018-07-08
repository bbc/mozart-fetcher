defmodule MozartFetcher.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias MozartFetcher.{Router}

  @opts Router.init([])

  describe "/status" do
    test "it will return 'OK'" do
      conn = conn(:get, "/status")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["text/plain; charset=utf-8"]
      assert conn.resp_body == "OK"
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
    test "it will return a JSON response" do
      json_body = ~s({
        "components": [{
                        "id": "stream-icons",
                        "endpoint": "https://s3-eu-west-1.amazonaws.com/shared-application-buckets-public-1pmfwo80l61it/load-tests/static_envelopes/25082016/small-1.0.4.json",
                        "must_succeed": true
                        }]
          }
)
      conn = conn(:post, "/collect", json_body)
      conn = Router.call(conn, @opts)

      expected_body = ~s({"components":[{"head":[],"bodyLast":[],"bodyInline":"<DIV id=\\\"site-container\\\" role=\\\"main\\\">"}]})

      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
      assert conn.resp_body == expected_body
    end
  end
end
