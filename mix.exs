defmodule Paraiso.MixProject do
  use Mix.Project

  def project do
    [
      app: :paraiso,
      version: "0.0.1",
      elixir: "~> 1.10",
      deps: deps(),
      package: package()
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
    [{:ex_doc, "~> 0.22", only: :dev, runtime: false}]
  end

  defp package() do
    [
      maintainers: ["Takeshi Horiuchi"],
      licenses: ["MIT Lisence"],
      links: %{"GitHub" => "https://github.com/keshihoriuchi/paraiso"}
    ]
  end
end
