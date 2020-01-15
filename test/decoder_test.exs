defmodule MozartFetcher.DecoderTest do
  use ExUnit.Case

  alias MozartFetcher.{Decoder, Config, Envelope}

  doctest Decoder

  describe "#decode_envelope" do
    test "when the JSON is successfully decoded it is transformed into a struct" do
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

    test "when the %Envelope{} isn't valid JSON we return an empty %Envelope" do
      json = ~s({"head":[],"bodyInLine":"<DIV id=\\"site-container\\">","bodyLast":[]})

      assert Decoder.decode_envelope(json, %Envelope{}) ==
               {:ok, %MozartFetcher.Envelope{bodyInline: "", bodyLast: [], head: []}}
    end
  end

  describe "#decode_config" do
    test "when the %Config{} is correct it returns a list of Config structs" do
      json = ~s({ "components\": [
                   {
                     "id": "stream-icons",
                     "endpoint": "localhost:8082/success",
                     "must_succeed": true,
                     "format": "envelope"
                   },
                   {
                     "id": "weather-forecast",
                     "endpoint": "localhost:8082/success",
                     "must_succeed": false,
                     "format": "envelope"
                   }
               ]})

      expected = {
        :ok,
        [
          %MozartFetcher.Config{
            endpoint: "localhost:8082/success",
            id: "stream-icons",
            must_succeed: true,
            format: "envelope"
          },
          %MozartFetcher.Config{
            endpoint: "localhost:8082/success",
            id: "weather-forecast",
            must_succeed: false,
            format: "envelope"
          }
        ]
      }

      assert Decoder.decode_config(json, %Config{}) == expected
    end
  end

  describe "when the map keys do not match the struct" do
    test "it returns an error" do
      json = ~s( "components": [{:"Foo": "Bar" }])
      assert Decoder.decode_config(json, %Config{}) == {:error}
    end
  end
end
