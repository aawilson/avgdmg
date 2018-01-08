defmodule AvgdmgStage.Worker do
  use GenStage

  # Client

  def start_link(opts = %{}) do
    {:ok, ruleset} = Map.fetch(opts, :ruleset)
    server_opts = Map.get(opts, :server_opts, [])
    genstage_opts = Map.get(opts, :genstage_opts, [])

    GenStage.start_link(__MODULE__, {ruleset, genstage_opts}, server_opts)
  end

  # Server

  def init({ruleset, genstage_opts}) do
    {:producer_consumer, %{requests: 0, ruleset: ruleset}, genstage_opts}
  end

  def handle_events(commands, _from, state) do
    results = Enum.map(commands, fn (command) ->
      AvgdmgStage.Commands.to_results(command, state[:ruleset])
    end)

    {:noreply, results, Map.put(state, :requests, state[:requests] + length(commands))}
  end
end
