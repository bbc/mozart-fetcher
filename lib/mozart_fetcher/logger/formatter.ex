defmodule MozartFetcher.Logger.Formatter do
  def format(level, message, _timestamp, metadata) do
    [
      Jason.encode!(
        Map.merge(
          %{
            datetime: DateTime.utc_now() |> DateTime.to_iso8601(),
            level: level,
            message: :erlang.iolist_to_binary(message)
          },
          to_json(Map.new(take_metadata(metadata)))
        )
      ),
      "\n"
    ]
  rescue
    _ ->
      "could not format message #{inspect({level, message, metadata})}\n"
  end

  defp take_metadata(metadata) do
    Keyword.drop(metadata, [
      :erl_level,
      :time,
      :application,
      :file,
      :line,
      :function,
      :module,
      :domain,
      :gl,
      :pid,
      :mfa
    ])
  end

  defp to_json(val = %{__struct__: _}) do
    to_json(Map.from_struct(val))
  end

  defp to_json(val) when is_map(val) do
    Enum.reduce(val, %{}, fn
      {k, val}, acc -> Map.put(acc, k, to_json(val))
    end)
  end

  defp to_json(val) when is_atom(val) or is_binary(val) or is_number(val) do
    val
  end

  defp to_json(val) when is_tuple(val) do
    Tuple.to_list(val)
    |> to_json()
  end

  defp to_json(val) when is_list(val) do
    Enum.map(val, &to_json/1)
  end

  defp to_json(val) do
    inspect(val)
  end
end
