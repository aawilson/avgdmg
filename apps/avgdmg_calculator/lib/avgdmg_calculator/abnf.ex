defmodule AvgdmgCalculator.ABNF do
  @moduledoc """
    Uses ex_abnf to parse commands
  """
  def init() do
    my_priv = :code.priv_dir :avgdmg_calculator
    ABNF.load_file "#{my_priv}/command.abnf"
  end

  def parse(grammar, input, rule \\ "command")

  def parse(grammar, input, rule) when is_binary(input) do
    parse(grammar, to_charlist(input), rule)
  end

  def parse(grammar, input, rule) do
    result = ABNF.apply grammar, rule, input, %{}
  end
end
