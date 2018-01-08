defmodule AvgdmgDiscordPosterTest do
  use ExUnit.Case
  doctest AvgdmgDiscord.Poster

  setup do
    {:ok, agent} = start_supervised MockApi
    %{agent: agent}
  end

  test "sends messages based on events", %{agent: _agent} do

    msg = %{content: "foobar", channel_id: 1}
    result = 1
    {:noreply, [], %{requests: 1, api: MockApi}} = AvgdmgDiscord.Poster.handle_events(
      [{msg, result}],
      :arbitrary,
      %{requests: 0, api: MockApi}
    )

    :ok = case MockApi.status do
      [{1, "1"}] -> :ok
      unexpected -> {:error, unexpected}
    end
  end
end

defmodule MockApi do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def create_message(channel_id, msg) do
    Agent.update(__MODULE__, fn (list) -> [{channel_id, msg} | list] end)
  end

  def status do
    Agent.get(__MODULE__, fn (list) -> list end)
  end
end
