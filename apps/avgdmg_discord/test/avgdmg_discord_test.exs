defmodule AvgdmgDiscordTest do
  use ExUnit.Case
  doctest AvgdmgDiscord

  test "filters events that aren't :MESSAGE_CREATE" do
    events = [{:NOT_MESSAGE_CREATE, {:arbitrary}, {:arbitrary}}]
    assert {:noreply, [], :arbitrary_state} == AvgdmgDiscord.handle_events(events, :arbitrary_from, :arbitrary_state)
  end

  test "allow :MESSAGE_CREATE filter on message content" do
    msg1 = %{content: "!ping"}
    events1 = [{:MESSAGE_CREATE, {msg1}, :arbitrary}]
    assert {:noreply, [{:ping, %{content: "", msg: msg1}}], :arbitrary_state} == AvgdmgDiscord.handle_events(events1, :arbitrary_from, :arbitrary_state)

    msg2 = %{content: "!avgdmg foo"}
    events2 = [{:MESSAGE_CREATE, {msg2}, :arbitrary}]
    assert {:noreply, [{:avgdmg, %{content: "foo", msg: msg2}}], :arbitrary_state} == AvgdmgDiscord.handle_events(events2, :arbitrary_from, :arbitrary_state)
  end
end
