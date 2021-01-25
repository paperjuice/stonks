defmodule Stonks.MixProject do
  use Mix.Project

  def project do
    [
      app: :stonks,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Stonks, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:uuid, "~> 1.1"}
    ]
  end
end
