defmodule MozartFetcher.Decoder do
  alias MozartFetcher.{Envelope, Config}

  def decode_envelope(data, struct) do
    with {:ok, decoded} <- Jason.decode(data, keys: :atoms),
         {:ok, struct} <- to_struct(decoded, struct) do
      {:ok, struct}
    else
      {:error, error = %Jason.DecodeError{}} ->
        Stump.log(:error, "Envelope decode error: #{error.data}")
        {:error}

      {:error, "Failed to convert map to struct"} ->
        {:error}
    end
  end

  # This could be more generic if we add a list_name then Enum.map(data[list_name]) instead of specifically for components here
  def decode_config(data, struct) do
    with {:ok, decoded} <- Jason.decode(data, keys: :atoms),
         {:ok, decoded} <- components_to_struct(decoded[:components], struct) do
      {:ok, decoded}
    else
      {:error, error = %Jason.DecodeError{}} ->
        Stump.log(:error, "Config decode error: #{error.data}")
        {:error}

      {:error, "Invalid Config list"} ->
        {:error}
    end
  end

  defp components_to_struct(components, struct) do
    component_list =
      Enum.map(components, fn map ->
        struct(struct, map)
      end)

    case Enum.any?(component_list, fn component ->
           component != {:error}
         end) do
      true -> {:ok, component_list}
      false -> {:error, "Invalid Config list"}
    end
  end

  defp to_struct(map, struct = %Envelope{}) do
    case struct(struct, map) do
      {:error} ->
        ExMetrics.increment("error.components.decode")

        Stump.log(:error, %{
          message: "Map contains invalid keys cannot convert to Envelope",
          map: map
        })

        {:error, "Failed to convert map to struct"}

      struct ->
        {:ok, struct}
    end
  end
end
