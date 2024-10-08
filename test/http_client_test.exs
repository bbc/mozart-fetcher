defmodule HTTPClientTest do
  use ExUnit.Case

  describe "get" do
    test "using a valid URL with no query string" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo/bar")
      assert resp.request.options[:recv_timeout] == MozartFetcher.content_timeout()
      assert resp.request_url == "http://localhost:8082/foo/bar"
    end

    test "using a valid URL with timeout" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo/bar?timeout=2")
      assert resp.request.options[:recv_timeout] == 2_000
      assert resp.request_url == "http://localhost:8082/foo/bar?timeout=2"
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

    test "the request headers contain a User-Agent header with the value MozartFetcher" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo/bar")
      assert {"User-Agent", "MozartFetcher"} in resp.request.headers
    end

    test "adds the ctx-unwrapped header for FABL requests" do
      defmodule MockClientSuccessfulResponseWithFablCtxUnwrappedHeader do
        def get(endpoint, headers, _) do
          {:ok,
           %HTTPoison.Response{
             request_url: "#{endpoint}/called",
             request: %HTTPoison.Request{
               url: endpoint,
               headers: headers
             }
           }}
        end
      end

      {:ok, resp} =
        HTTPClient.get(
          "https://fabl.api.something/test",
          _headers = [{"ctx-unwrapped", "1"}],
          MockClientSuccessfulResponseWithFablCtxUnwrappedHeader
        )

      assert {"ctx-unwrapped", "1"} in resp.request.headers
    end

    test "adds the ctx-service-env header for FABL requests" do
      defmodule MockClientSuccessfulResponseWithFablCtxServiceEnvHeader do
        def get(endpoint, headers, _) do
          {:ok,
           %HTTPoison.Response{
             request_url: "#{endpoint}/called",
             request: %HTTPoison.Request{
               url: endpoint,
               headers: headers
             }
           }}
        end
      end

      {:ok, resp} =
        HTTPClient.get(
          "https://fabl.api.something/test",
          _headers = [{"ctx-service-env", "test"}],
          MockClientSuccessfulResponseWithFablCtxServiceEnvHeader
        )

      assert {"ctx-service-env", "test"} in resp.request.headers
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
        HTTPClient.get("http://localhost:8082/foo", _headers = [], MockClientSuccessfulResponse)

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
        HTTPClient.get(
          "http://localhost:8082/foo",
          _headers = [],
          MockClientClosedResponseSuccessfulSecondTime
        )

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
          _headers = [],
          MockClientClosedResponseUnsuccessfulSecondTime
        )

      assert returned_response == {:error, %HTTPoison.Error{id: nil, reason: :closed}}
    end

    test "catches exception" do
      defmodule MockClientRaisesException do
        def get(_, _, _) do
          raise "Something went wrong!"
        end
      end

      returned_response =
        HTTPClient.get(
          "http://localhost:8082/foo",
          _headers = [],
          MockClientRaisesException
        )

      assert returned_response == {:error, %HTTPoison.Error{id: nil, reason: :unexpected}}
    end

    test "uncompresses a gzipped response" do
      defmodule MockCompressedSuccessfulResponse do
        def get(_, _, _) do
          {:ok,
           %HTTPoison.Response{
             headers: [{"content-encoding", "gzip"}],
             body: :zlib.gzip("Hello world!"),
             status_code: 200
           }}
        end
      end

      returned_response =
        HTTPClient.get(
          "http://localhost:8082/foo",
          _headers = [],
          MockCompressedSuccessfulResponse
        )

      assert returned_response ==
               {:ok,
                %HTTPoison.Response{
                  body: "Hello world!",
                  headers: [{"content-encoding", "gzip"}],
                  request: nil,
                  status_code: 200
                }}
    end
  end
end
