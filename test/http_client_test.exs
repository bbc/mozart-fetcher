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

    test "the request headers contain a User-Agent header with the value Mozart-Fetcher" do
      {:ok, resp} = HTTPClient.get("http://localhost:8082/foo/bar")
      assert Enum.member?(resp.request.headers, {'User-Agent', 'Mozart-Fetcher'}) == true
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

    test "catches exception" do
      defmodule MockClientRaisesException do
        def get(_, _, _) do
          raise "Something went wrong!"
        end
      end

      returned_response =
        HTTPClient.get(
          "http://localhost:8082/foo",
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
        HTTPClient.get("http://localhost:8082/foo", MockCompressedSuccessfulResponse)

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
