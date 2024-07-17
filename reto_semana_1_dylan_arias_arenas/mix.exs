defmodule RetoSemana1DylanAriasArenas.MixProject do
  @moduledoc """
  Este módulo define la configuración del proyecto Mix para `Reto Semana 1`.

  Contiene las especificaciones del proyecto, las aplicaciones adicionales y las dependencias.
  """

  use Mix.Project

  def project do
    [
      app: :reto_semana_1_dylan_arias_arenas,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.1.1"},
      {:credo, "~> 1.7.7", only: [:dev, :test], runtime: false}
    ]
  end
end
