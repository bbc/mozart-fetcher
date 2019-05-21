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
end
