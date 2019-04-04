defmodule MozartFetcher.Decoder do
  def data_to_struct(data, as: a_struct) do
    case Jason.decode(data) do
      {:ok, decoded} -> {:ok, to_struct(decoded, as: a_struct)}
      {:error, _}    -> {:error}
    end
  end

  def list_to_struct_list(data, struct) do
    case Jason.decode(data) do
      {:ok, data} ->
        {:ok, Enum.map(data["components"], fn x -> to_struct(x, as: struct) end)}
      {:error, _} -> {:error}
    end
  end

  def to_struct(a_map, as: a_struct) do
    keys = Map.keys(a_struct) 
            |> Enum.filter(fn x -> x != :__struct__ end)
    processed_map =
    for key <- keys, into: %{} do
        value = Map.get(a_map, key) || Map.get(a_map, to_string(key))
        {key, value}
      end
    a_struct = Map.merge(a_struct, processed_map)
    a_struct
  end
end