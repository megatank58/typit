defmodule Typit.MixProject do
  use Mix.Project

  def project do
    [
      app: :typit,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Typit, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nosedrum, github: "jchristgit/nosedrum", override: true},
      {:nostrum, "~> 0.10.4"},
      {:dotenvy, "~> 1.0.0"},
      {:rambo, "~> 0.3"}
    ]
  end
end
