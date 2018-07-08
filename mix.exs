defmodule MozartFetcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :fetcher,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :poison, :httpoison],
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
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
