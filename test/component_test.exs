defmodule MozartFetcher.ComponentTest do
  use ExUnit.Case, async: false

  import Mock

  alias MozartFetcher.{Component, FakeClient}

  doctest MozartFetcher.Component

  describe "fetch components" do
    test "it returns the response body when succesfull" do
      with_mock HTTPClient, [get: fn(_url) -> FakeClient.returning(:success) end] do
        component = %Component{endpoint: "http://localhost/foo"}
        assert Component.fetch(component) == {:ok, "{\"some\":\"data\"}"}
      end
    end

    test "it returns an error in case of timeout" do
      with_mock HTTPClient, [get: fn(_url) -> FakeClient.returning(:timeout) end] do
        component = %Component{endpoint: "http://localhost/foo"}
        assert Component.fetch(component) == {:error, :timeout}
      end
    end
  end
end
