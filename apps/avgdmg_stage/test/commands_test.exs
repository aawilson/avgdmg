defmodule AvgdmgStageCommandsTest do
  use ExUnit.Case
  doctest AvgdmgStage.Commands

  test "to_results avgdmg tests" do
    content1 = "Attack: +19 to hit, reach 25 ft., one target. Hit: (4d8 + 10) piercing damage. vs 25"
    assert AvgdmgStage.Commands.to_results({:avgdmg, %{msg: "foobar", content: content1}}, AvgdmgCalculator.Ruleset.FifthEd) == {
      "foobar",
      "Average damage for `#{content1}`:\n`22.40`",
    }

    content2 = "Attack: +19 to hit, reach 25 ft., one target. Hit: (4d8 + 10) piercing damage. vs 25-26"
    assert AvgdmgStage.Commands.to_results({:avgdmg, %{msg: "foobar", content: content2}}, AvgdmgCalculator.Ruleset.FifthEd) == {
      "foobar",
      "Average damage for `#{content2}`:\n`22.40, 21.00`",
    }
  end
  # def handle_events(events, _from, state) do
  #   events = Enum.map(events, fn (%{args: {ac, bonus, crit_multiplying_damage_dice, opts}}) ->
  #     state[:ruleset].avgdmg(ac, bonus, crit_multiplying_damage_dice, opts)
  #   end)

  #   {:noreply, events, Map.put(state, :requests, state[:requests] + length(events))}
  # end

end
