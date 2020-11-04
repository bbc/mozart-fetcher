defmodule MozartFetcher.DecoderTest do
  use ExUnit.Case

  alias MozartFetcher.{Decoder, Config}

  doctest Decoder

  describe "#decode_config" do
    test "when the JSON is valid it is is transformed into a list of Config structs" do
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

    test "when the JSON is invalid we return an error" do
      json = ~s( "components": [{:"Foo": "Bar" }])
      assert Decoder.decode_config(json, %Config{}) == {:error}
    end
  end
end
