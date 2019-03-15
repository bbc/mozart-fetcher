defmodule MozartFetcher.EnvelopeTest do
  use ExUnit.Case

  alias MozartFetcher.{Envelope}

  doctest Envelope

  describe "build an envelope" do
    test "it parse the json body to an Envelope" do
      component = ~s({"head":[],"bodyInline":"<DIV id=\\"site-container\\">","bodyLast":[]})

      assert Envelope.build(component) == %Envelope{
               head: [],
               bodyInline: ~s(<DIV id="site-container">),
               bodyLast: []
             }
    end

    test "it returns an empty Envelope if not valid content" do
      component = "{"
      assert Envelope.build(component) == %Envelope{}
    end
  end
end
