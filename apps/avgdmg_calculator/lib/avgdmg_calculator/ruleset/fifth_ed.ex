defmodule AvgdmgCalculator.Ruleset.FifthEd do
  @moduledoc """
  D&D Fifth Edition ruleset.
  """
  alias Decimal, as: D

  defp pow(n, k), do: pow(n, k, 1)
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)

  defp rolls_that_hit(ac, bonus) do
    max(1, min((21 - ac + bonus), 19))
  end

  @doc """
  Calculates the ratio of attacks against a given ac with a given bonus that hit.
  Accepts a `:strategy` option that can be `:advantage`, `:disadvantage`, or
  `:normal` (the default) to make it best of two, worst of two, or single-die,
  respectively.

  ## Examples

  iex> AvgdmgCalculator.Ruleset.FifthEd.to_hit(12, 1)
  #Decimal<0.5>

  iex> AvgdmgCalculator.Ruleset.FifthEd.to_hit(25, 1)
  #Decimal<0.05>

  iex> AvgdmgCalculator.Ruleset.FifthEd.to_hit(12, 1, strategy: :advantage)
  #Decimal<0.75>

  iex> AvgdmgCalculator.Ruleset.FifthEd.to_hit(12, 1, strategy: :disadvantage)
  #Decimal<0.25>
  """

  def to_hit(ac, bonus, opts \\ [])

  def to_hit(ac, bonus, opts) when not is_atom(opts) do
    strategy = opts[:strategy] || :normal
    to_hit(ac, bonus, strategy)
  end

  def to_hit(ac, bonus, :advantage) do
    h = rolls_that_hit(ac, bonus)
    numerator = D.new(((h * 40) - (pow(h, 2))))
    D.div(numerator, D.new(400))
  end

  def to_hit(ac, bonus, :disadvantage) do
    h = 20 - rolls_that_hit(ac, bonus)
    numerator = D.new(400 - (h * 40) + (pow(h, 2)))
    D.div(numerator, D.new(400))
  end

  def to_hit(ac, bonus, :normal) do
    D.div(D.new(rolls_that_hit(ac, bonus)), D.new(20))
  end

  @doc """
  Calculate the ratio of attacks that crit. In 5e, this is almost always 0.05,
  but it does accept a `:threat` option to change the minimum number that triggers
  a critical.

  ## Examples

  iex> AvgdmgCalculator.Ruleset.FifthEd.to_crit()
  #Decimal<0.05>

  iex> AvgdmgCalculator.Ruleset.FifthEd.to_crit(threat: 19)
  #Decimal<0.1>
  """
  def to_crit(opts \\ []) do
    threat = opts[:threat] || 20
    to_hit(threat, 0, opts)
  end

  @doc """
  Parse
  ## Examples

  iex> AvgdmgCalculator.Ruleset.FifthEd.parse_for_avgdmg("1d20 + 6 2d8+4 vs 10")
  {10, 6, "2d8+4", []}

  iex> AvgdmgCalculator.Ruleset.FifthEd.parse_for_avgdmg("Melee Weapon Attack: +2 to hit, reach 5 ft., one target. Hit: 2 (1d4 + 2) bludgeoning damage. vs 10")
  {10, 2, "1d4 + 2", []}

  iex> AvgdmgCalculator.Ruleset.FifthEd.parse_for_avgdmg("Melee Weapon Attack: -11 to hit, Hit: 2 (6d6-3) with disadvantage vs 10")
  {10, -11, "6d6-3", strategy: :disadvantage}

  iex> AvgdmgCalculator.Ruleset.FifthEd.parse_for_avgdmg("1d20 + 6 2d8+4 with advantage vs 10")
  {10, 6, "2d8+4", strategy: :advantage}
  """

  @avgdmg_parse_re ~r/^(?|(?:1?d20)?\s*([+-]?\s*\d+)\s*(.+\d)|.*attack:\s*([+-]?\s*\d+)\s*to\s*hit\s*.*hit:\s*(?:\d+\s*)?\((.*)\)).*?(?:with (?:((?:dis)?adv)(?:antage)?))?\s*vs\.?\s*(\d+)(?:\-(\d+))?\s*(?:ac\s*)?$/i

  ["Melee Weapon Attack: +2 to hit, reach 5 ft., one target. Hit: 2 (1d4 + 2) bludgeoning damage. vs 10", "+2", "1d4 + 2", "", "10"]
  def parse_for_avgdmg(to_parse) do
    case Regex.run(@avgdmg_parse_re, to_parse) do
      [_ | rest] ->
        {bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low, ac_high} = match_regex(rest)
        opts = case adv_or_disadv do
          "adv" -> [strategy: :advantage]
          "disadv" -> [strategy: :disadvantage]
          "" -> []
        end

        [{ac_low, _}, {ac_high, _}, {bonus, _}] = [ac_low, ac_high, bonus]
        |> Enum.map(fn (arg) ->
          arg
          |> String.replace(~r/\s+/, "")
          |> Integer.parse
        end)

        case Enum.any?([ac_low, ac_high, bonus], fn
          :error -> true
          _ -> false
        end) do
          true -> {:error, "one of #{ac_low}, #{ac_high} or #{bonus} failed to parse to an integer"}
          false when ac_low == ac_high -> {ac_low, bonus, crit_multiplying_damage_dice, opts}
          false -> {ac_low, ac_high, bonus, crit_multiplying_damage_dice, opts}
        end
      nil -> :nomatch
    end
  end

  defp match_regex([bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low]), do: {bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low, ac_low}
  defp match_regex([bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low, ""]), do: {bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low, ac_low}
  defp match_regex([bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low, ac_high]), do: {bonus, crit_multiplying_damage_dice, adv_or_disadv, ac_low, ac_high}

  @doc """
  Calculate the expected mean of an arbitrarily large number of rolls against a
  particular ac with a particular bonus and damage dice. Accepts the same
  `:strategy` and `:threat` options as `to_hit` and `to_crit`, as well as a
  `:non_crit_multiplying_dice` option to allow for damage that doesn't multiply
  on crit. Uses Float math, so it will sometimes have funny results.

  TODO: allow damage dice to be typed, use a real decimal library

  ## Examples

  iex> AvgdmgCalculator.Ruleset.FifthEd.avgdmg({12, 1, "1d6", []})
  #Decimal<1.925>

  iex> AvgdmgCalculator.Ruleset.FifthEd.avgdmg(12, 1, "1d6")
  #Decimal<1.925>

  iex> AvgdmgCalculator.Ruleset.FifthEd.avgdmg(12, 1, "1d6", strategy: :advantage)
  #Decimal<2.96625>

  iex> AvgdmgCalculator.Ruleset.FifthEd.avgdmg(12, 1, "1d6", strategy: :disadvantage)
  #Decimal<0.88375>
  """
  def avgdmg({ac, bonus, crit_multiplying_damage_dice, opts}) do
    avgdmg(ac, bonus, crit_multiplying_damage_dice, opts)
  end

  def avgdmg({ac_low, ac_high, bonus, crit_multiplying_damage_dice, opts}) do
    Enum.map(ac_low..ac_high, fn (x)->
      avgdmg(x, bonus, crit_multiplying_damage_dice, opts)
    end)
  end

  def avgdmg(:error) do
    :error
  end

  def avgdmg(ac, bonus, crit_multiplying_damage_dice, opts \\ []) do
    non_crit_multiplying_damage_dice = opts[:non_crit_multiplying_damage_dice] || ""
    crit_multiplier = 2

    crit_multiplying_average = AvgdmgCalculator.Dice.average(crit_multiplying_damage_dice)
    non_crit_multiplying_average = AvgdmgCalculator.Dice.average(non_crit_multiplying_damage_dice)

    {th, tc} = {to_hit(ac, bonus, opts), to_crit(opts)}
    damage_without_crit = D.add(crit_multiplying_average, non_crit_multiplying_average)
    damage_crit_only = D.mult(crit_multiplying_average, D.new(crit_multiplier - 1))

    avgdmg_without_crit = D.mult(th, damage_without_crit)
    avgdmg_crit_only = D.mult(tc, damage_crit_only)

    # to_hit(ac, bonus, opts) * (normdmg) + to_crit(opts) * crit_multiplying_average * (crit_multiplier - 1)
    D.add(avgdmg_without_crit, avgdmg_crit_only)
  end
end
