defmodule MozartFetcher.MixProject do
  use Mix.Project

  @version "1.0.0"
  def project do
    [
      app: :mozart_fetcher,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug, :httpoison, :con_cache],
      mod: {MozartFetcher.Application, [env: Mix.env()]}
    ]
  end

  defp releases do
    [
      mozart_fetcher: [
        version: @version,
        validate_compile_env: false,
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        steps: [:assemble, :tar],
        include_erts: true,
        include_src: false
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.8"},
      {:httpoison, "~> 1.8"},
      {:con_cache, "~> 1.0"},
      {:parse_trans, "~> 3.4", override: true},
      {:hackney, "~> 1.20.1"},
      {:telemetry, "~> 1.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_metrics_statsd, "~> 0.7"},
      {:logger_file_backend, "~> 0.0.10"},
      {:jason, "~> 1.3"}
    ]
  end
end
