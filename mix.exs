defmodule ChartsLive.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :charts_live,
      version: "0.1.0",
      elixir: "~> 1.13.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:credo, "~> 1.6.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28.5", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15.0", only: :test},
      {:phoenix_live_view, "~> 0.18.2"},
      {:charts, github: "jrissler/charts"}
      # {:charts, path: "../charts"}
    ]
  end
end
