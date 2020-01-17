defmodule MozartFetcher.Decoder do
  alias MozartFetcher.{Envelope, Config}

  def decode_envelope(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, decoded} ->
        to_struct(decoded, struct)

      {:error, error = %Jason.DecodeError{}} ->
        Stump.log(:error, "Envelope decode error: #{error.data}")
        {:error}
    end
  end

  def decode_config(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, decoded} ->
        {:ok, components_to_struct(decoded[:components], struct)}

      {:error, error = %Jason.DecodeError{}} ->
        Stump.log(:error, "Config decode error: #{error.data}")
        {:error}
    end
  end

  defp components_to_struct(components, struct) do
    Enum.map(components, fn map ->
      struct(struct, map)
    end)
  end

  defp to_struct(map, struct = %Envelope{}) do
    try do
      {:ok, struct!(struct, map)}
    rescue
      KeyError ->
        ExMetrics.increment("error.envelope.decode")

        Stump.log(:error, %{
          message: "Map contains invalid keys cannot convert to Envelope",
          map: map
        })

        {:ok, %Envelope{}}
    end
  end
end
