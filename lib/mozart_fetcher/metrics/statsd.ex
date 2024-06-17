defmodule MozartFetcher.Metrics.Statsd do
  use MozartFetcher.MetricDefinitions,
    backend: :statsd,
    metrics: [
      :fetcher_metrics
    ]

  def last_value(metric_name, opts \\ []) do
    apply_metric(:last_value, metric_name, opts)
  end

  def counter(metric_name, opts \\ []) do
    apply_metric(:counter, metric_name, opts)
  end

  def summary(metric_name, opts \\ []) do
    apply_metric(:summary, metric_name, opts)
  end

  defp apply_metric(type, metric_name, opts) do
    opts = Keyword.update(opts, :tags, [:BBCEnvironment], fn tags -> [:BBCEnvironment | tags] end)
    apply(Telemetry.Metrics, type, [metric_name, opts])
  end
end
