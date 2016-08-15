defmodule URLChecker.Mixfile do
  use Mix.Project

  def project do
    [app: :url_checker,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: [],
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {URLChecker, []},
     applications: [:phoenix, :cowboy, :logger, :gettext, :httpotion]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:httpotion, "~> 3.0.0"},
      {:phoenix, "~> 1.2.0"},
      {:poolboy, "~> 1.5"},
      {:redix, "~> 0.4.0"},
    ]
  end
end
