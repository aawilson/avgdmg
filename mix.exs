defmodule Avgdmg.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:gun, git: "https://github.com/ninenines/gun.git", ref: "dd1bfe4d6f9fb277781d922aa8bbb5648b3e6756", override: true},
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:decimal, "~> 1.0"},
      {:ex_abnf, "~> 0.2.8"},
    ]
  end
end
