defmodule MozartFetcher.Decoder do
  require Logger
  alias MozartFetcher.Envelope

  def decode_envelope(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, decoded} ->
        to_envelope(decoded, struct)

      {:error, error = %Jason.DecodeError{}} ->
        Logger.error("Envelope Jason decode error: #{error.data}")
        {:error}
    end
  end

  def decode_config(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, decoded} ->
        {:ok, components_to_struct(decoded[:components], struct)}

      {:error, error = %Jason.DecodeError{}} ->
        Logger.error("Config decode error: #{error.data}")
        {:error}
    end
  end

  defp components_to_struct(components, struct) do
    Enum.map(components, fn map ->
      struct(struct, map)
    end)
  end

  defp to_envelope(map, struct = %Envelope{}) do
    try do
      {:ok, struct!(struct, map)}
    rescue
      KeyError ->
        Logger.error("Map contains invalid keys cannot convert to Envelope", %{
          map: map
        })

        {:error}
    end
  end
end
