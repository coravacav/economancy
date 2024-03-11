defmodule Economancy.MixProject do
  use Mix.Project

  def project do
    [
      app: :economancy,
      version: "0.1.0",
      elixir: "~> 1.16",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp escript do
    [main_module: Economancy.CLI]
  end

  defp deps do
    [
      {:jason, "~> 1.4"}
    ]
  end
end
