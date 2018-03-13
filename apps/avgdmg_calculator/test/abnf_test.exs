defmodule AvgdmgCalculator.ABNFTest do
  use ExUnit.Case, async: true

  setup_all do
    grammar = AvgdmgCalculator.ABNF.init
    {:ok, %{grammar: grammar}}
  end

  test "one attack", context do
    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 vs 10"
    ).values
    assert values[:ac] == 10..10
    assert values[:attacks] == [{2, "1d6"}]
    assert values[:opts] == []

    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "1d6 vs 10"
    ).values
    assert values[:attacks] == [{0, "1d6"}]

    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 with advantage vs 10"
    ).values
    assert values[:opts] == [advantage: :advantage]
  end

  test "forms of advantage", context do
    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 with adv vs 10"
    ).values
    assert values[:opts] == [advantage: :advantage]

    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 with disadv vs 10"
    ).values
    assert values[:opts] == [advantage: :disadvantage]
  end

  test "ac formats", context do
    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 vs 10-"
    ).values
    assert values[:ac] == 10..10

    # TODO: negative AC at some point maybe
    assert AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 vs -10"
    ) == nil

    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6 with disadv vs 20-10"
    ).values
    assert values[:ac] == 20..10
  end

  test "all clauses", context do
    [values | _] = AvgdmgCalculator.ABNF.parse(
      context[:grammar],
      "+2 1d6,-3 2d6 + 1d4 with advantage reroll 19 noncrit 1d6 + 2d7 lucky elvishaccuracy vs 10-20"
    ).values
    assert values[:ac] == 10..20
    assert values[:attacks] == [{2, "1d6"}, {-3, "2d6+1d4"}]
    assert values[:opts] == [
      advantage: :advantage, reroll: 19,
      non_crit_multiplying_damage_dice: "1d6+2d7", lucky: true,
      elvishaccuracy: true
    ]
  end
end
