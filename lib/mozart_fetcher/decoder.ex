defmodule MozartFetcher.Decoder do
  alias MozartFetcher.Config
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
end
