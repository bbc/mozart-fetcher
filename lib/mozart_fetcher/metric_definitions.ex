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
          counter("success.components.decode", event_name: [:success, :components, :decode]),
          counter("error.components.decode", event_name: [:error, :components, :decode]),
          counter("error.empty_component_list", event_name: [:error, :empty_component_list]),
          summary("function.timing.fetcher.process",
            event_name: [:function, :timing, :fetcher, :process],
            measurement: :duration
          ),
          summary("function.timing.http_client.get",
            event_name: [:function, :timing, :http_client, :get],
            measurement: :duration
          ),
          counter("http.component.retry", event_name: [:http, :component, :retry]),
          counter("http.component.error", event_name: [:http, :component, :error]),
          counter("success.component.process",
            event_name: [:success, :component, :process],
            tags: [:status_code, :component_id]
          ),
          counter("error.component.process",
            event_name: [:error, :component, :process],
            tags: [:status_code, :component_id]
          ),
          counter("web.request.count", event_name: [:web, :request, :count]),
          counter("web.response.count", event_name: [:web, :response, :count]),
          counter("web.response.status",
            event_name: [:web, :response, :status],
            tags: [:status_code]
          ),
          counter("web.response.timing",
            event_name: [:web, :response, :timing],
            tags: [:status_code]
          ),
          counter("web.response.timing.page", event_name: [:web, :response, :timing, :page])
        ]
      end
    end
  end
end
