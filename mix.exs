defmodule ChartsLive.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :charts_live,
      version: "0.1.0",
      elixir: "~> 1.16.0",
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
      {:credo, "~> 1.7.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18.0", only: :test},
      {:phoenix_live_view, "~> 0.20.2"},
      # remove phoenix_html_helpers once all older helpers are removed
      # {:phoenix_html_helpers, "~> 1.0.1"},
      {:phoenix_html, "~> 3.3.3", overwrite: true},
      {:number, "~> 1.0.4"},
      {:charts, github: "jrissler/charts"}
      # {:charts, path: "../charts"}
    ]
  end
end
