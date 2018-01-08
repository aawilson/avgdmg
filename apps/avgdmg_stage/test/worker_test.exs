defmodule AvgdmgStageWorkerTest do
  use ExUnit.Case
  doctest AvgdmgStage.Worker

  test "filters events that aren't :MESSAGE_CREATE" do
    events = [{:NOT_MESSAGE_CREATE, {:arbitrary}, {:arbitrary}}]
    filter = fn (_msg) -> :should_not_reach end
    assert {:noreply, [], filter} == AvgdmgDiscord.handle_events(events, :arbitrary, filter)
  end
  # def handle_events(events, _from, state) do
  #   events = Enum.map(events, fn (%{args: {ac, bonus, crit_multiplying_damage_dice, opts}}) ->
  #     state[:ruleset].avgdmg(ac, bonus, crit_multiplying_damage_dice, opts)
  #   end)

  #   {:noreply, events, Map.put(state, :requests, state[:requests] + length(events))}
  # end

end
