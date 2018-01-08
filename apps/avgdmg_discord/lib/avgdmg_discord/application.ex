defmodule AvgdmgDiscord.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {AvgdmgDiscord, name: AvgdmgDiscord.App},
      {AvgdmgStage.Worker, %{ruleset: AvgdmgCalculator.Ruleset.FifthEd, genstage_opts: [subscribe_to: [AvgdmgDiscord.App]], server_opts: [name: AvgdmgDiscord.App.Worker]}},
      {AvgdmgDiscord.Poster, %{genstage_opts: [subscribe_to: [AvgdmgDiscord.App.Worker]]}},
    ]

    opts = [strategy: :one_for_one, name: AvgdmgDiscord.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
