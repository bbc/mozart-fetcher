defmodule MozartFetcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :mozart_fetcher,
      version: "1.0.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :httpoison, :con_cache],
      mod: {MozartFetcher.Application, [env: Mix.env()]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0.1"},
      {:httpoison, "~> 1.5"},
      {:con_cache, "~> 0.13.0"},
      {:distillery, "~> 2.0", runtime: false},
      {:parse_trans, "~> 3.2.0"},
      {:ex_metrics, git: "https://github.com/bbc/ExMetrics.git"},
      {:stump, "~> 1.5.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:jason, "~> 1.1"}
    ]
  end
end
