defmodule Ofx.MixProject do
  use Mix.Project

  @version "0.0.10"
  @description "A lib to parse and generate OFX data"
  @links %{"GitHub" => "https://github.com/danielwsx64/ofx"}

  def project do
    [
      app: :ofx,
      version: @version,
      name: "Ofx",
      docs: docs(),
      description: @description,
      elixir: "~> 1.8",
      package: package(),
      source_url: @links["GitHub"],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, ">= 0.6.6"},

      # Dev/Test dependencies

      {:credo, "~> 1.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.4", only: [:dev, :test]},
      {:tzdata, "~> 1.1"}
    ]
  end

  defp package do
    [licenses: ["Apache-2.0"], links: @links]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "Get starting"]
      ]
    ]
  end
end
