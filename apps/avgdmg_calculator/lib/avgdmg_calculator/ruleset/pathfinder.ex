defmodule AvgdmgCalculator.Ruleset.Pathfinder do
  @moduledoc """
  Pathfinder ruleset.
  """

  @doc """
  Calculates the ratio of attacks against a given ac with a given bonus that hit.
  """
  alias Decimal, as: D

  def to_hit(ac, bonus) do
    D.max(D.new(0.05), D.min(D.div(D.new(21 - ac + bonus), D.new(20.0)), D.new(0.95)))
  end

  @doc """
  Calculates the ratio of attacks against a given ac with a given bonus that crit.
  Accepts a `:confirm_bonus` option that adds to confirmation rolls after a threat,
  and a `:threat` option to modify the minimum roll that triggers a threat.
  """
  def to_crit(ac, bonus, opts \\ []) do
    confirm_bonus = opts[:confirm_bonus] || 0
    threat = opts[:threat] || 20
    D.mult(D.min(D.div(D.new(21 - threat), D.new(20.0)), to_hit(ac, bonus)), to_hit(ac, bonus + confirm_bonus))
  end

  @doc """
  Calculate the expected mean of an arbitrarily large number of rolls
  against a   particular ac with a particular bonus and damage dice. Accepts the
  same   options as `to_crit`, as well as a   `:non_crit_multiplying_dice` option
  to allow for damage that doesn't multiply   on crit, and a `:crit_multiplier`
  option to modify how much crits add. Uses Float math, so it will sometimes have
  funny results.
  """
  def avgdmg(ac, bonus, crit_multiplying_damage_dice, opts \\ []) do
    non_crit_multiplying_damage_dice = opts[:non_crit_multiplying_damage_dice] || ""
    crit_multiplier = opts[:crit_multiplier] || 2

    crit_multiplying_average = AvgdmgCalculator.Dice.average(crit_multiplying_damage_dice)
    non_crit_multiplying_average = AvgdmgCalculator.Dice.average(non_crit_multiplying_damage_dice)

    {th, tc} = {to_hit(ac, bonus), to_crit(ac, bonus, opts)}
    damage_without_crit = D.add(crit_multiplying_average, non_crit_multiplying_average)
    damage_crit_only = D.mult(crit_multiplying_average, D.new(crit_multiplier - 1))

    avgdmg_without_crit = D.mult(th, damage_without_crit)
    avgdmg_crit_only = D.mult(tc, damage_crit_only)

    # to_hit(ac, bonus) * (
    #   crit_multiplying_average + non_crit_multiplying_average
    # ) + to_crit(ac, bonus, opts) * crit_multiplying_average * (crit_multiplier - 1)
    D.add(avgdmg_without_crit, avgdmg_crit_only)
  end
end
