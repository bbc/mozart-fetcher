defmodule MozartFetcher.IntegrationTest do
  use ExUnit.Case
  use Plug.Test
  alias MozartFetcher.Router
  @opts Router.init([])

  describe "when fetching a small component" do
    test "it will return a JSON response" do
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
                bodyInline: "<DIV id=\"site-container\">",
                bodyLast: []
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

  describe "when fetching a big component" do
    test "it will return a JSON response" do
      json_body = ~s({
        "components": [{
                        "id": "big-component",
                        "endpoint": "localhost:8082/big_component",
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
              id: "big-component",
              envelope: %{
                head: [],
                bodyInline:
                  "<DIV id=\"big-component\" class=\"big\"><h1>This is a really big component</h1></DIV>",
                bodyLast: []
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

  describe "fetching multiple components" do
    test "when all of the components are successful they all have a status of 200" do
      json_body = ~s({
        "components": [{ "id": "news-front-page",
                        "endpoint": "localhost:8082/success",
                        "must_succeed": true
                        },
                        {
                          "id": "weather-front-page",
                          "endpoint": "localhost:8082/success",
                          "must_succeed": true
                        },
                        {
                          "id": "weather-component",
                          "endpoint": "localhost:8082/big_component",
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
              id: "news-front-page",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline: "<DIV id=\"site-container\">"
              }
            },
            %{
              status: 200,
              index: 1,
              id: "weather-front-page",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline: "<DIV id=\"site-container\">"
              }
            },
            %{
              status: 200,
              index: 2,
              id: "weather-component",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline:
                  "<DIV id=\"big-component\" class=\"big\"><h1>This is a really big component</h1></DIV>"
              }
            }
          ]
        })

      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
      assert conn.resp_body == expected_body
    end

    test "when one of the components is invalid" do
      json_body = ~s({
        "components": [{ "foo": "bar",
                        },
                        {
                          "id": "weather-component",
                          "endpoint": "localhost:8082/big_component",
                          "must_succeed": true
                        }]
                      }
                    )
      conn = conn(:post, "/collect", json_body)
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 500
      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
      assert conn.resp_body == "Internal Server Error"
    end
  end

  describe "when fetching a component returns a 404" do
    test "it returns a 200, with the failing component status set as 404 and its original id still set" do
      json_body = ~s({
        "components": [{
                        "id": "news-front-page",
                        "endpoint": "localhost:8082/non_200_status/404",
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
              status: 404,
              index: 0,
              id: "news-front-page",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline: ""
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

  describe "when fetching the component times out" do
    test "it returns a 200, with the failing component status set as 408 and its original id still set" do
      json_body = ~s({
        "components": [{
                        "id": "weather-front-page",
                        "endpoint": "localhost:8082/non_200_status/408",
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
              status: 408,
              index: 0,
              id: "weather-front-page",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline: ""
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

  describe "when fetching the component receives a server error" do
    test "it returns a 200, with the failing component status set as 500 and its original id still set" do
      json_body = ~s({
        "components": [{
                        "id": "weather-front-page",
                        "endpoint": "localhost:8082/non_200_status/500",
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
              status: 500,
              index: 0,
              id: "weather-front-page",
              envelope: %{
                head: [],
                bodyLast: [],
                bodyInline: ""
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
