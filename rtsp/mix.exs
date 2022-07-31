defmodule Rtsp.MixProject do
  use Mix.Project

  def project do
    [
      app: :rtsp,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {Rtsp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 5.0"},
      {:toml, "~> 0.6.2"}
    ]
  end
end
