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
      mod: {MozartFetcher.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.6.1"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:con_cache, "~> 0.13.0"},
      {:distillery, "~> 2.0", runtime: false},
      {:mock, "~> 0.3.0", only: :test},
      {:parse_trans, "~> 3.2.0"}

    ]
  end
end
