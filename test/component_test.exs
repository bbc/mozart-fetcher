defmodule MozartFetcher.ComponentTest do
  use ExUnit.Case, async: false

  import Mock

  alias MozartFetcher.{Component, FakeClient}

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
        component = %Component{endpoint: "http://localhost/foo"}
        assert Component.fetch(component) == {:ok, "{\"some\":\"data\"}"}
      end
    end

    test "it returns an error in case of timeout" do
      with_http_response(:timeout) do
        component = %Component{endpoint: "http://localhost/foo"}
        assert Component.fetch(component) == {:error, :timeout}
      end
    end

    test "it returns an error in case service is down" do
      with_http_response(:down) do
        component = %Component{endpoint: "http://localhost/foo"}
        assert Component.fetch(component) == {:error, :econnrefused}
      end
    end
  end
end
