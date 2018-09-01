defmodule Bucketier.MixProject do
  use Mix.Project

  def project do
    [
      app: :bucketier,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: "readme",
        logo: "assets/bucketier.png",
        extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bucketier.Application, []}
    ]
  end

  def description,
    do: ~S"""
      **Bucketier** is a simple _Dictionary_ application you can use to store
      data in a simple _Bucket_ (Key/Value store).
    """

  def package() do
    [
      name: "bucketier",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["andreas@altendorfer.at"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/iboard/bucketier",
        "Documentation" => "https://hexdocs.pm/bucketier/readme.html"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
