defmodule MozartFetcher.TimeoutParserTest do
  use ExUnit.Case

  alias MozartFetcher.TimeoutParser

  describe "a valid timeout present  in the query string" do
    test "it returns the qs value as an integer" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?b=1&timeout=4") == 4
    end
  end

  describe "a valid timeout as query string" do
    test "it returns the qs value as an integer" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?timeout=5") == 5
    end
  end

  describe "no valid timeout in the query string" do
    test "it returns the default timeout" do
      assert TimeoutParser.parse("http://origin.bbc.com/comp/a?a=1") == MozartFetcher.content_timeout()
    end
  end
end
