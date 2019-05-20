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

    test "makes only one request on success" do
      defmodule MockClientSuccessfulResponse do
        def get(endpoint, _, _) do
          {:ok,
           %HTTPoison.Response{
             request_url: "#{endpoint}/called"
           }}
        end
      end

      returned_response =
        HTTPClient.get("http://localhost:8082/foo", MockClientSuccessfulResponse)

      assert returned_response ==
               {:ok, %HTTPoison.Response{request_url: "http://localhost:8082/foo/called"}}
    end

    test "makes request twice on connection closed and successful second time" do
      defmodule MockClientClosedResponseSuccessfulSecondTime do
        @responses [
          {:error,
           %HTTPoison.Error{
             reason: :closed
           }},
          {:ok,
           %HTTPoison.Response{
             request_url: "http://localhost:8082/foo/called"
           }}
        ]

        def start_link do
          Agent.start_link(fn -> @responses end, name: __MODULE__)
        end

        def get(_, _, _) do
          Agent.get_and_update(__MODULE__, fn responses -> List.pop_at(responses, 0) end)
        end
      end

      MockClientClosedResponseSuccessfulSecondTime.start_link()

      returned_response =
        HTTPClient.get("http://localhost:8082/foo", MockClientClosedResponseSuccessfulSecondTime)

      assert returned_response ==
               {:ok, %HTTPoison.Response{request_url: "http://localhost:8082/foo/called"}}
    end

    test "makes request twice on connection closed and unsuccessful second time" do
      defmodule MockClientClosedResponseUnsuccessfulSecondTime do
        def get(_, _, _) do
          {:error,
           %HTTPoison.Error{
             reason: :closed
           }}
        end
      end

      returned_response =
        HTTPClient.get(
          "http://localhost:8082/foo",
          MockClientClosedResponseUnsuccessfulSecondTime
        )

      assert returned_response == {:error, %HTTPoison.Error{id: nil, reason: :closed}}
    end

    test "makes request twice on connection timeout and successful second time" do
      defmodule MockClientTimeoutResponseSuccessfulSecondTime do
        @responses [
          {:error,
           %HTTPoison.Error{
             reason: :timeout
           }},
          {:ok,
           %HTTPoison.Response{
             request_url: "http://localhost:8082/foo/called"
           }}
        ]

        def start_link do
          Agent.start_link(fn -> @responses end, name: __MODULE__)
        end

        def get(_, _, _) do
          Agent.get_and_update(__MODULE__, fn responses -> List.pop_at(responses, 0) end)
        end
      end

      MockClientTimeoutResponseSuccessfulSecondTime.start_link()

      returned_response =
        HTTPClient.get("http://localhost:8082/foo", MockClientTimeoutResponseSuccessfulSecondTime)

      assert returned_response ==
               {:ok, %HTTPoison.Response{request_url: "http://localhost:8082/foo/called"}}
    end

    test "makes request twice on connection timeout and unsuccessful second time" do
      defmodule MockClientTimeoutResponseUnsuccessfulSecondTime do
        def get(_, _, _) do
          {:error,
           %HTTPoison.Error{
             reason: :timeout
           }}
        end
      end

      returned_response =
        HTTPClient.get(
          "http://localhost:8082/foo",
          MockClientTimeoutResponseUnsuccessfulSecondTime
        )

      assert returned_response == {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
    end
  end
end
