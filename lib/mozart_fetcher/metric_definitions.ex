defmodule MozartFetcher.MetricDefinitions do
  defmacro __using__(opts) do
    backend = Keyword.get(opts, :backend)
    metrics = Keyword.get(opts, :metrics)

    quote do
      @backend unquote(backend)
      def metrics do
        unquote(metrics)
        |> Enum.flat_map(fn metric ->
          apply(__MODULE__, metric, [])
        end)
      end

      def fetcher_metrics() do
        [
          counter("success.components.decode"),
          counter("error.components.decode"),
          counter("error.empty_component_list"),
          summary("function.timing.fetcher.process",
            event_name: [:function, :timing, :fetcher, :process],
            measurement: :duration,
            unit: {:native, :millisecond}
          ),
          summary("function.timing.http_client.get",
            event_name: [:function, :timing, :http_client, :get],
            measurement: :duration,
            unit: {:native, :millisecond}
          ),
          counter("http.component.retry"),
          counter("http.component.error"),
          counter("success.component.process",
            event_name: [:success, :component, :process],
            tags: [:status_code, :component_id]
          ),
          counter("error.component.process",
            event_name: [:error, :component, :process],
            tags: [:status_code, :component_id]
          )
        ]
      end
    end
  end
end
