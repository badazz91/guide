defmodule Guide.MixProject do
  @moduledoc false
  use Mix.Project

  @source_url "https://github.com/badazz91/guide"
  @version "0.0.2"

  def project do
    [
      app: :guide,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Tool that turns sobelow static code analysis results into markdown",
      name: "Guide",
      homepage_url: "https://hexdocs.pm/guide",
      docs: docs(),
      aliases: aliases(),
      escript: [main_module: Mix.Tasks.Guide],
      test_coverage: [tool: ExCoveralls, export: "cov"],
      preferred_cli_env: [
        coveralls: :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.1"},
      {:earmark, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:excoveralls, "~> 0.18", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.1", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Robin Demuth"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end

  defp aliases do
    [
      "test.all": [
        "hex.audit",
        "format --check-formatted",
        "compile --warnings-as-errors",
        "deps.unlock --check-unused",
        "credo --all --strict"
      ]
    ]
  end
end
