defmodule Paraiso.MixProject do
  use Mix.Project

  def project do
    [
      app: :paraiso,
      version: "0.0.8",
      elixir: "~> 1.10",
      deps: deps(),
      package: package(),
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [
      extra_applications: [
        # :logger
      ]
    ]
  end

  defp deps do
    [{:ex_doc, "~> 0.24", only: :dev, runtime: false}]
  end

  defp package() do
    [
      maintainers: ["Takeshi Horiuchi"],
      licenses: ["MIT Lisence"],
      description: "Validation and sanitization library for nested objects and arrays",
      links: %{"GitHub" => "https://github.com/keshihoriuchi/paraiso"}
    ]
  end
end
