defmodule MozartFetcher.ComponentTest do
  use ExUnit.Case, async: false

  import Mock

  alias MozartFetcher.{Component, Config, FakeClient}

  doctest Component

  defmacro with_http_response(state, block) do
    quote do
      with_mock HTTPClient, get: fn _url -> FakeClient.returning(unquote(state)) end do
        unquote(block)
      end
    end
  end

  describe "fetch components" do
    test "it returns the response body when succesfull" do
      with_http_response(:success) do
        config = %Config{endpoint: "http://localhost/foo"}

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
    end

    test "it returns an error in case of timeout" do
      with_http_response(:timeout) do
        config = %Config{endpoint: "http://localhost/foo"}
        assert Component.fetch(config) == {:error, :timeout}
      end
    end

    test "it returns an error in case service is down" do
      with_http_response(:down) do
        config = %Config{endpoint: "http://localhost/foo"}
        assert Component.fetch(config) == {:error, :econnrefused}
      end
    end
  end
end
