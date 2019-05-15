defmodule HTTPClientTest do
  use ExUnit.Case

  describe "get" do
    test "using a valid URL" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo/bar")
      assert resp.request_url == "http://localhost:8082/foo/bar"
    end

    test "using a URL containing white spaces" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo bar")
      assert resp.request_url == "http://localhost:8082/foo%20bar"
    end

    test "using a URL containing multiple white spaces" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo   bar")
      assert resp.request_url == "http://localhost:8082/foo%20%20%20bar"
    end

    test "using a URL containing encoded chars" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo%22bar")
      assert resp.request_url == "http://localhost:8082/foo%22bar"
    end

    test "using a URL containing a query string and spaces" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo bar?baz= true")
      assert resp.request_url == "http://localhost:8082/foo%20bar?baz=%20true"
    end
  end
end
