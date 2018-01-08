defmodule AvgdmgCalculator.DiceTest do
  use ExUnit.Case, async: true
  doctest AvgdmgCalculator.Dice, except: [roll: 1]

  test "parses empty string" do
    assert AvgdmgCalculator.Dice.parse("") == []
  end

  test "parses regular constant" do
    assert AvgdmgCalculator.Dice.parse("1") == [1]
  end

  test "parses negative constant" do
    assert AvgdmgCalculator.Dice.parse("-2") == [-2]
  end

  test "parses d-form constant" do
    assert AvgdmgCalculator.Dice.parse("3d1") == [3]
  end

  test "parses negative d-form constant" do
    assert AvgdmgCalculator.Dice.parse("-4d1") == [-4]
  end

  test "parses positive non-constant" do
    assert AvgdmgCalculator.Dice.parse("5d6") == [
      %{sign: 1, num: 5, size: 6}
    ]
  end

  test "parses negative non-constant" do
    assert AvgdmgCalculator.Dice.parse("-7d8") == [
      %{sign: -1, num: 7, size: 8}
    ]
  end

  test "parses composite constants" do
    assert AvgdmgCalculator.Dice.parse("9 + 10") == [9, 10]
  end

  test "parses composite constants with negative" do
    assert AvgdmgCalculator.Dice.parse("11 - 12") == [11, -12]
  end

  test "parses composite non-constants" do
    assert AvgdmgCalculator.Dice.parse("13d14 + 15d16") == [
      %{sign: 1, num: 13, size: 14},
      %{sign: 1, num: 15, size: 16},
    ]
  end

  test "parses composite non-constants with negative" do
    assert AvgdmgCalculator.Dice.parse("17d18 - 19d20") == [
      %{sign: 1, num: 17, size: 18},
      %{sign: -1, num: 19, size: 20},
    ]
  end

  test "parses composite constant with non-constant" do
    assert AvgdmgCalculator.Dice.parse("21 + 22d23") == [
      21,
      %{sign: 1, num: 22, size: 23},
    ]
  end

  test "is case-insensitive" do
    assert AvgdmgCalculator.Dice.parse("24D25") == [
      %{sign: 1, num: 24, size: 25},
    ]
  end

  test "doesn't mind weird spacing" do
    assert AvgdmgCalculator.Dice.parse("     -  26d27    +28-29d30        ") == [
      %{sign: -1, num: 26, size: 27},
      28,
      %{sign: -1, num: 29, size: 30},
    ]
  end

  test "roll a string" do
    assert Enum.member?(1..6, AvgdmgCalculator.Dice.roll("1d6"))
  end

  test "roll a negative" do
    assert Enum.member?(-2..-10, AvgdmgCalculator.Dice.roll("-2d5"))
  end

  test "'roll' a constant" do
    assert AvgdmgCalculator.Dice.roll("5") == 5
  end

  test "roll composite" do
    assert Enum.member?(3..16, AvgdmgCalculator.Dice.roll("2d6 + 1d4"))
  end

  test "roll map" do
    assert Enum.member?(1..4, AvgdmgCalculator.Dice.roll([
        %{sign: 1, num: 1, size: 4}
      ]))
  end

  test "average a string" do
    assert AvgdmgCalculator.Dice.average("1d6") == Decimal.new(3.5)
  end

  test "average a negative" do
    assert AvgdmgCalculator.Dice.average("-2d5") == Decimal.new(-6)
  end

  test "average a constant" do
    assert AvgdmgCalculator.Dice.average("5") == Decimal.new(5)
  end

  test "average a composite" do
    assert AvgdmgCalculator.Dice.average("2d6 + 1d4") == Decimal.new(9.5)
  end

  test "average map" do
    assert AvgdmgCalculator.Dice.average([
        %{sign: 1, num: 1, size: 4}
      ]) == Decimal.new(2.5)
  end
end
