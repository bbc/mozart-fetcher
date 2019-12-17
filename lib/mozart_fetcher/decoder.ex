defmodule MozartFetcher.Decoder do
  def data_to_struct(data, struct) do
    with {:ok, decoded} <- Jason.decode(data, keys: :atoms),
         {:ok, struct} <- to_struct(decoded, struct) do
      {:ok, struct}
    else
      _ -> {:error}
    end
  end

  # This could be more generic if we add a list_name then Enum.map(data[list_name]) instead of specifically for components here
  def list_to_struct_list(data, struct) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, data} ->
        {:ok,
         Enum.map(data[:components], fn map ->
           case to_struct(map, struct) do
             {:error, _} -> {:error}
             {:ok, struct} -> struct
           end
         end)}

      {:error, _} ->
        {:error}
    end
  end

  def to_struct(map, struct) do
    case Map.keys(Map.from_struct(struct)) |> Enum.all?(&Map.has_key?(map, &1)) do
      true ->
        case struct(struct, map) do
          struct -> {:ok, struct}
        end

      false ->
        ExMetrics.increment("error.components.decode")
        Stump.log(:error, %{message: "Invalid keys passed to to_struct", map: map})
        {:error, "Failed to validate keys in struct"}
    end
  end
end
