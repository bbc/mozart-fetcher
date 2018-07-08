defmodule MozartFetcher.EnvelopeTest do
  use ExUnit.Case

  alias MozartFetcher.{Envelope}

  doctest Envelope

  describe "build an envelope" do
    test "it parse the json body to an Envelope" do
      body = ~s({"head":[],"bodyInline":"<DIV id=\\"site-container\\">","bodyLast":[]})

      assert Envelope.build(body) == %Envelope{head: [],
                                               bodyInline: ~s(<DIV id="site-container">),
                                               bodyLast: []}
    end


    test "it returns an empty Envelope if not valid content" do
      body = "redirecting to..."
      assert Envelope.build(body) == %Envelope{head: [],
                                               bodyInline: "",
                                                        bodyLast: []}
    end

    test "it returns an empty Envelope if body is nil" do
      body = nil
      assert Envelope.build(body) == %Envelope{head: [],
                                               bodyInline: "",
                                               bodyLast: []}
    end

  end
end
