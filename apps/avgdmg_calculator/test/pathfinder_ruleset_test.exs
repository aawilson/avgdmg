defmodule AvgdmgCalculator.Ruleset.PathfinderTest do
  use ExUnit.Case, async: true
  doctest AvgdmgCalculator.Ruleset.Pathfinder

  @onetwentieth Decimal.new(0.05)
  @onetenth Decimal.new(0.10)
  @onequarter Decimal.new(0.25)
  @onefourhundredth Decimal.mult(@onetwentieth, @onetwentieth)
  @nineteentwentieths Decimal.new(0.95)

  test "to hit 0 bonus ac 19" do
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_hit(19, 0) == @onetenth
  end

  test "to hit 0 bonus ac 20" do
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_hit(20, 0) == @onetwentieth
  end

  test "to hit" do
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_hit(21, 0) == @onetwentieth
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_hit(11, 10) == @nineteentwentieths
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_hit(10, 10) == @nineteentwentieths
  end

  test "to crit" do
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(20, 0) == @onefourhundredth
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(21, 0) == @onefourhundredth
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(19, 0) == Decimal.mult(@onetwentieth, @onetenth)
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(20, 0, threat: 19) == @onefourhundredth
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(20, 0, threat: 19, confirm_bonus: 4) == Decimal.mult(@onetwentieth, @onequarter)
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(11, 10, threat: 19) == Decimal.mult(@onetenth, @nineteentwentieths)
    assert AvgdmgCalculator.Ruleset.Pathfinder.to_crit(19, 0, threat: 19) == Decimal.mult(@onetenth, @onetenth)
  end

  test "avgdmg" do
    assert AvgdmgCalculator.Ruleset.Pathfinder.avgdmg(20, 0, "1") == Decimal.add(@onetwentieth, @onefourhundredth)
    assert AvgdmgCalculator.Ruleset.Pathfinder.avgdmg(20, 0, "1", crit_multiplier: 3) == Decimal.add(@onetwentieth, Decimal.mult(@onefourhundredth, Decimal.new(2)))
    assert AvgdmgCalculator.Ruleset.Pathfinder.avgdmg(20, 0, "1", crit_multiplier: 3) == Decimal.add(@onetwentieth, Decimal.mult(@onefourhundredth, Decimal.new(2)))
  end
end
