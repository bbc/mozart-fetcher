defmodule MozartFetcher.ComponentTest do
  use ExUnit.Case

  alias MozartFetcher.{Component, Config}

  doctest Component

  describe "fetch components" do
    test "it returns the response body when succesfull" do
      config = %Config{endpoint: "http://localhost:8082/success"}

      expected = %MozartFetcher.Component{
        envelope: %MozartFetcher.Envelope{
          bodyInline: "<DIV id=\"site-container\">",
          bodyLast: [],
          head: []
        },
        id: nil,
        index: 0,
        status: 200
      }

      assert Component.fetch(config) == expected
    end

    test "it returns empty envelope when 202" do
      config = %Config{endpoint: "http://localhost:8082/non_200_status/202"}

      expected = %MozartFetcher.Component{
        envelope: %MozartFetcher.Envelope{},
        id: nil,
        index: 0,
        status: 202
      }

      assert Component.fetch(config) == expected
    end

    test "it returns empty envelope when 404" do
      config = %Config{endpoint: "http://localhost:8082/non_200_status/404"}

      expected = %MozartFetcher.Component{
        envelope: %MozartFetcher.Envelope{},
        id: nil,
        index: 0,
        status: 404
      }

      assert Component.fetch(config) == expected
    end

    test "it returns an error in case of timeout" do
      config = %Config{endpoint: "http://localhost:8082/timeout"}
      assert Component.fetch(config) == {:error, :timeout}
    end

    test "it returns an error in case service is down" do
      config = %Config{endpoint: "http://localhost:9090/fails"}
      assert Component.fetch(config) == {:error, :econnrefused}
    end
  end
end
