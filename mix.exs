defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      # prune_code_paths: Mix.env() == :prod,
      app: :servy,
      description: "A humble HTTP server",
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :observer, :wx, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:poison, "~> 6.0"},
      {:earmark, "~> 1.4"}
    ]
  end
end
