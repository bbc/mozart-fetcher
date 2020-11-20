defmodule MozartFetcher.DecoderTest do
  use ExUnit.Case

  alias MozartFetcher.{Decoder, Config, Envelope}

  doctest Decoder

  describe "#decode_envelope" do
    test "when the JSON is successfully decoded it is transformed into an Envelope" do
      json = ~s({"head":[],"bodyInline":"<DIV id=\\"site-container\\">","bodyLast":[]})

      expected =
        {:ok,
         %Envelope{
           head: [],
           bodyInline: ~s(<DIV id="site-container">),
           bodyLast: []
         }}

      assert Decoder.decode_envelope(json, %Envelope{}) == expected
    end

    test "when the JSON contains invalid keys for an %Envelope{} we return an error" do
      json = ~s({"head":[],"foobar":"<DIV id=\\"site-container\\">","bodyLast":[]})

      assert Decoder.decode_envelope(json, %Envelope{}) == {:error}
    end
  end

  describe "#decode_config" do
    test "when the JSON is valid it is is transformed into a list of Config structs" do
      json = ~s({ "components\": [
                   {
                     "id": "stream-icons",
                     "endpoint": "localhost:8082/success",
                     "must_succeed": true
                   },
                   {
                     "id": "weather-forecast",
                     "endpoint": "localhost:8082/success",
                     "must_succeed": false
                   }
               ]})

      expected = {
        :ok,
        [
          %MozartFetcher.Config{
            endpoint: "localhost:8082/success",
            id: "stream-icons",
            must_succeed: true
          },
          %MozartFetcher.Config{
            endpoint: "localhost:8082/success",
            id: "weather-forecast",
            must_succeed: false
          }
        ]
      }

      assert Decoder.decode_config(json, %Config{}) == expected
    end

    test "when the JSON is invalid we return an error" do
      json = ~s( "components": [{:"Foo": "Bar" }])
      assert Decoder.decode_config(json, %Config{}) == {:error}
    end
  end
end
