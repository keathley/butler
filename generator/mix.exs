defmodule Butler.New.Mixfile do
  use Mix.Project

  def project do
    [
      app: :butler_new,
      version: "0.6.0",
      elixir: "~> 1.1.0"
    ]
  end

  def application do
    [applications: []]
  end
end
