defmodule MozartFetcher.Decoder do
  alias MozartFetcher.{Envelope, Config}

  def decode_envelope(data, struct) do
    with {:ok, decoded} <- Jason.decode(data, keys: :atoms),
         {:ok, struct} <- to_struct(decoded, struct) do
      {:ok, struct}
    else
      _ -> {:error}
    end
  end

  # This could be more generic if we add a list_name then Enum.map(data[list_name]) instead of specifically for components here
  def decode_config(data, struct) do
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

  def to_struct(map, struct = %Config{}) do
    case [:endpoint, :format, :id, :must_succeed] |> Enum.all?(&Map.has_key?(map, &1)) do
      true ->
        {:ok, struct(struct, map)}

      false ->
        ExMetrics.increment("error.components.decode")

        Stump.log(:error, %{
          message: "Map contains Invalid keys cannot convert to Config",
          map: map
        })

        {:error, "Failed to validate keys in struct"}
    end
  end

  def to_struct(map, struct = %Envelope{}) do
    case [:head, :bodyInline, :bodyLast] |> Enum.all?(&Map.has_key?(map, &1)) do
      true ->
        {:ok, struct(struct, map)}

      false ->
        ExMetrics.increment("error.components.decode")

        Stump.log(:error, %{
          message: "Map contains Invalid keys cannot convert to Envelope",
          map: map
        })

        {:error, "Failed to validate keys in struct"}
    end
  end
end
