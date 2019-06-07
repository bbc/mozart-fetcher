defmodule MozartFetcher.Decoder do
  def data_to_struct(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, decoded} -> {:ok, to_struct(decoded, struct)}
      {:error, _}    -> {:error}
    end
  end

  # This could be more generic if we add a list_name then Enum.map(data[list_name]) instead of specifically for components here
  def list_to_struct_list(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, data} ->
        {:ok, Enum.map(data[:components], fn map -> to_struct(map, struct) end)}
      {:error, _} -> {:error}
    end
  end

  defp to_struct(map, struct) do
    case struct!(struct, map) do
      {:error} ->
        ExMetrics.increment("error.components.decode")
        Stump.log(:error, %{message: "Invalid keys passed to to_struct", map: map})
        {:error}
      struct -> struct
    end
  end
end