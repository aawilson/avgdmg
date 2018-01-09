defmodule AvgdmgCalculator.Ruleset.FifthEdTest do
  use ExUnit.Case, async: true
  doctest AvgdmgCalculator.Ruleset.FifthEd

  test "to_hit" do
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(19, 0) == Decimal.new(0.10)
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(20, 0) == Decimal.new(0.05)
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(21, 0) == Decimal.new(0.05)
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(11, 10) == Decimal.new(0.95)
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(10, 10) == Decimal.new(0.95)

    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(19, 0, strategy: :advantage) == Decimal.div(Decimal.new(76), Decimal.new(400))  # 0.19
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(20, 0, strategy: :advantage) == Decimal.div(Decimal.new(39), Decimal.new(400))  # 0.0975
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(21, 0, strategy: :advantage) == Decimal.div(Decimal.new(39), Decimal.new(400))  # 0.0975
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(11, 10, strategy: :advantage) == Decimal.div(Decimal.new(399), Decimal.new(400))  # 0.9975
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(10, 10, strategy: :advantage) == Decimal.div(Decimal.new(399), Decimal.new(400))  # 0.9975

    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(19, 0, strategy: :disadvantage) == Decimal.div(Decimal.new(4), Decimal.new(400))  # 0.01
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(20, 0, strategy: :disadvantage) == Decimal.div(Decimal.new(1), Decimal.new(400))  # 0.0025
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(21, 0, strategy: :disadvantage) == Decimal.div(Decimal.new(1), Decimal.new(400))  # 0.0025
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(11, 10, strategy: :disadvantage) == Decimal.div(Decimal.new(361), Decimal.new(400))  # 0.9025
    assert AvgdmgCalculator.Ruleset.FifthEd.to_hit(10, 10, strategy: :disadvantage) == Decimal.div(Decimal.new(361), Decimal.new(400))  # 0.9025
  end

  test "to_crit" do
    assert AvgdmgCalculator.Ruleset.FifthEd.to_crit() == Decimal.new(0.05)
    assert AvgdmgCalculator.Ruleset.FifthEd.to_crit(threat: 19) == Decimal.new(0.10)
    assert AvgdmgCalculator.Ruleset.FifthEd.to_crit(strategy: :advantage) == Decimal.div(Decimal.new(39), Decimal.new(400))
    assert AvgdmgCalculator.Ruleset.FifthEd.to_crit(strategy: :disadvantage) == Decimal.div(Decimal.new(1), Decimal.new(400))
    assert AvgdmgCalculator.Ruleset.FifthEd.to_crit(threat: 19, strategy: :advantage) == Decimal.div(Decimal.new(76), Decimal.new(400))
    assert AvgdmgCalculator.Ruleset.FifthEd.to_crit(threat: 19, strategy: :disadvantage) == Decimal.div(Decimal.new(4), Decimal.new(400))
  end

  test "avgdmg" do
    assert AvgdmgCalculator.Ruleset.FifthEd.avgdmg(20, 0, "1") == Decimal.add(Decimal.new(0.05), Decimal.new(0.05))
    assert Enum.map(AvgdmgCalculator.Ruleset.FifthEd.avgdmg({6, 12, 1, "1d6", []}), fn (i) -> "#{i}" end) == ["2.975", "2.800", "2.625", "2.450", "2.275", "2.100", "1.925"]
  end
end
