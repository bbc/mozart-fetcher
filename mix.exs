defmodule MozartFetcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :mozart_fetcher,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :poison, :httpoison, :con_cache],
      mod: {MozartFetcher.Application, [env: Mix.env()]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0.1"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.5"},
      {:con_cache, "~> 0.13.0"},
      {:distillery, "~> 2.0", runtime: false},
      {:parse_trans, "~> 3.2.0"},
      {:ex_metrics, git: "https://github.com/bbc/ExMetrics.git"},
      {:stump, git: "https://github.com/JoeARO/stump.git"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
