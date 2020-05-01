defmodule AvgdmgCalculator.Dice do
  @moduledoc """
  Translates [x]d[y] + [z] into a parsed object for general use, and does
  calculations based on that.
  """

  alias Decimal, as: D

  @dice_re ~r/(\+|\-)?\s*(?:(?:(\d+)?(d))?(\d+))/i

  @doc """
  Works on a list of parseable objects

  ## Examples
      iex> AvgdmgCalculator.Dice.parse_list(["1d6", "1d4"])
      [[%{num: 1, sign: 1, size: 6}], [%{num: 1, sign: 1, size: 4}]]

  """
  def parse_list(to_parse) do
    Enum.map to_parse, &parse/1
  end

  @doc """
  Parses a string of the form ([x]d[y]|[z])( + ...) into a list of parsed items
  of component pieces. These items are either a constant, or a Map with keys
  :num (the number of dice being rolled), :sign (positive or negative term), and
  size (the size of the dice being rolled).

  ## Examples
      iex> AvgdmgCalculator.Dice.parse("3d6 + 2 - 4d4")
      [%{num: 3, sign: 1, size: 6}, 2, %{num: 4, sign: -1, size: 4}]

  """
  def parse(to_parse) when is_binary(to_parse) do
    Regex.scan(@dice_re, to_parse)
    |> Enum.map(fn
      [_, sign, _, "", const] ->
        sign_to_int(sign) * elem(Integer.parse(const), 0)
      [_, sign, const, _, "1"] ->
        sign_to_int(sign) * elem(Integer.parse(const), 0)
      [_, sign, num, _, size] ->
        %{sign: sign_to_int(sign), num: elem(Integer.parse(num), 0), size: elem(Integer.parse(size), 0)}
      nil -> :nomatch
    end)
  end


  @doc """
  Generates random numbers based on the given die spec, either as an unparsed string
  or as a result of a parse/1 call.

  ## Examples
      iex> AvgdmgCalculator.Dice.roll("2d6")
      7

      iex> AvgdmgCalculator.Dice.roll([%{num: 2, sign: 1, size: 6}])
      11
  """

  def roll(dice) when is_binary(dice) do
    parse(dice) |> roll
  end

  def roll(dice) do
    Enum.reduce(dice, 0, fn
      member, acc when is_integer(member) -> acc + member
      %{sign: sign, num: num, size: size}, acc ->
        acc + sign * Enum.reduce(1..num, 0, fn _, inside_acc -> inside_acc + :rand.uniform(size) end)
      end
    )
  end

  @doc """
  Calculates the average result of a roll. Accepts both strings and parsed objects.

  ## Examples
      iex> AvgdmgCalculator.Dice.average("2d6")
      #Decimal<7>

      iex> AvgdmgCalculator.Dice.average([%{num: 2, sign: 1, size: 6}])
      #Decimal<7>
  """
  def average(dice) when is_binary(dice) do
    parse(dice) |> average
  end

  def average(dice) do
    Enum.reduce(dice, D.new(0), fn
      member, acc when is_integer(member) -> D.add(acc, D.new(member))
      %{sign: sign, num: num, size: size}, acc ->
        D.add(acc, D.div(D.new(sign * num * (1 + size)), D.new(2.0)))
      end
    )
  end

  ###

  defp sign_to_int("-") do
    -1
  end

  defp sign_to_int(_) do
    1
  end
end
