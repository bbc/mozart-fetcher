defmodule MozartFetcher.ComponentTest do
  use ExUnit.Case

  alias MozartFetcher.{Component, Config, Envelope}

  doctest Component

  describe "fetch components" do
    test "it returns the response body when successful" do
      config = %Config{endpoint: "http://localhost:8082/success", id: "news-top-stories"}

      expected = %{
        envelope: %Envelope{
          bodyInline: "<DIV id=\"site-container\">",
          bodyLast: [],
          head: []
        },
        id: "news-top-stories",
        index: 0,
        status: 200
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns the raw json response body when requesting a successful ares component" do
      config = %Config{
        endpoint: "http://localhost:8082/json_data",
        id: "article-data",
        format: "ares"
      }

      expected = %{
        data: %{
          content: %{
            some: "json data"
          }
        },
        id: "article-data",
        index: 0,
        status: 200
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns empty envelope when 202" do
      config = %Config{
        endpoint: "http://localhost:8082/non_200_status/202",
        id: "news_navigation"
      }

      expected = %{
        envelope: %Envelope{},
        id: "news_navigation",
        index: 0,
        status: 202
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns empty envelope when 404" do
      config = %Config{
        endpoint: "http://localhost:8082/non_200_status/404",
        id: "weather-forecast"
      }

      expected = %{
        envelope: %Envelope{},
        id: "weather-forecast",
        index: 0,
        status: 404
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns an error in case of timeout" do
      expected = %{
        envelope: %Envelope{
          bodyInline: "",
          bodyLast: [],
          head: []
        },
        id: "news_navigation",
        index: 0,
        status: 408
      }

      config = %Config{endpoint: "http://localhost:8082/timeout", id: "news_navigation"}
      assert Component.fetch({config, 0}) == expected
    end

    test "it returns an error in case service is down" do
      expected = %{
        envelope: %Envelope{
          bodyInline: "",
          bodyLast: [],
          head: []
        },
        id: "news-top-stories",
        index: 0,
        status: 500
      }

      config = %Config{endpoint: "http://localhost:9090/fails", id: "news-top-stories"}
      assert Component.fetch({config, 0}) == expected
    end

    test "it returns an error when requesting an ares component but the data is not valid json" do
      config = %Config{
        endpoint: "http://localhost:8082/invalid_json_data",
        id: "article-data",
        format: "ares"
      }

      expected = %{
        data: %{},
        id: "article-data",
        index: 0,
        status: 500
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns an error when requesting an ares component but the data is not found" do
      config = %Config{
        endpoint: "http://localhost:8082/non_200_status/404",
        id: "article-data",
        format: "ares"
      }

      expected = %{
        data: %{},
        id: "article-data",
        index: 0,
        status: 404
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns an error when requesting an ares component but it times out timeout" do
      config = %Config{
        endpoint: "http://localhost:8082/timeout",
        id: "article-data",
        format: "ares"
      }

      expected = %{
        data: %{},
        id: "article-data",
        index: 0,
        status: 408
      }

      assert Component.fetch({config, 0}) == expected
    end

    test "it returns an error when requesting an ares componnet but the service is down" do
      config = %Config{
        endpoint: "http://localhost:9090/fails",
        id: "article-data",
        format: "ares"
      }

      expected = %{
        data: %{},
        id: "article-data",
        index: 0,
        status: 500
      }

      assert Component.fetch({config, 0}) == expected
    end
  end
end
