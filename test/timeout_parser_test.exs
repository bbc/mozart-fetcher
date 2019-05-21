defmodule MozartFetcher.TimeoutParserTest do
  use ExUnit.Case

  alias MozartFetcher.TimeoutParser

  describe "a valid timeout present in the query string" do
    test "it returns the qs value as an integer" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?b=1&timeout=4&c=d") == 4_000
    end
  end

  describe "a valid timeout as query string" do
    test "it returns the qs value as an integer" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?timeout=5") == 5_000
    end
  end

  describe "a timeout of 0 in the query string" do
    test "it returns the default timeout" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?timeout=0") ==
               MozartFetcher.content_timeout()
    end
  end

  describe "a string as the timeout in the query string" do
    test "it returns the default timeout" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?timeout=abc") ==
               MozartFetcher.content_timeout()
    end
  end

  describe "a timeout query string key with empty value" do
    test "it returns the default timeout" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?timeout=") ==
               MozartFetcher.content_timeout()
    end
  end

  describe "a timeout query string key only" do
    test "it returns the default timeout" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?timeout") ==
               MozartFetcher.content_timeout()
    end
  end

  describe "no valid timeout in the query string" do
    test "it returns the default timeout" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?a=1") ==
               MozartFetcher.content_timeout()
    end
  end

  describe "all components have timeouts" do
    test "it returns the maximum timeout" do
      assert TimeoutParser.max_timeout([
               %{endpoint: "http://origin.bbc.com/comp/a?timeout=3"},
               %{endpoint: "http://origin.bbc.com/comp/b?timeout=1"}
             ]) ==
               3000
    end
  end

  describe "no components have timeouts" do
    test "it returns the maximum timeout" do
      assert TimeoutParser.max_timeout([
               %{endpoint: "http://origin.bbc.com/comp/a"},
               %{endpoint: "http://origin.bbc.com/comp/b"}
             ]) ==
               MozartFetcher.content_timeout()
    end
  end

  describe "some components have timeouts" do
    test "it returns the maximum timeout" do
      assert TimeoutParser.max_timeout([
               %{endpoint: "http://origin.bbc.com/comp/a?timeout=5"},
               %{endpoint: "http://origin.bbc.com/comp/b"}
             ]) ==
               5000
    end
  end
end
