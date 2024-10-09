defmodule Ballot.MixProject do
  use Mix.Project

  def project do
    [
      app: :ballot,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Ballot.Application, []}
    ]
  end

  defp deps do
    [
      {:libring, "~> 1.7"},
      {:libcluster, "~> 3.4"}
    ]
  end
end
