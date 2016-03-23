defmodule Tlv.Mixfile do
  use Mix.Project

  def project do
    [app: :tlv,
     version: "0.1.0",
     elixir: "~> 1.2",
     description: "Encodes/Decodes BER-TLVs structures",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
    ]
  end

  defp package do
    [
      maintainers: ["Michele Balistreri"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bitgamma/elixir_tlv"}
    ]
  end
end
