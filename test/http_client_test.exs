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
  end
end
