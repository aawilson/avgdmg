defmodule AvgdmgDiscord.Poster do
  use GenStage
  alias Nostrum.Api

  # Client

  def start_link(opts = %{}) do
    api = Map.get(opts, :api, Api)
    server_opts = Map.get(opts, :server_opts, [])
    genstage_opts = Map.get(opts, :genstage_opts, [])

    GenStage.start_link(__MODULE__, {api, genstage_opts}, server_opts)
  end

  # Server

  def init({api, genstage_opts}) do
    {:consumer, %{requests: 0, api: api}, genstage_opts}
  end

  def handle_events(events, _from, %{requests: requests, api: api}) do
    Enum.each(events, fn ({msg, result}) ->
      api.create_message(msg.channel_id, "#{result}")
    end)

    {:noreply, [], %{requests: requests + length(events), api: api}}
  end
end
