defmodule AvgdmgStage.Commands do
  def parse_command("!ping" <> rest) do
    {:ping, String.trim(rest)}
  end

  def parse_command("!avgdmg" <> rest) do
    {:avgdmg, String.trim(rest)}
  end

  def parse_command("!help" <> rest) do
    {:help, String.trim(rest)}
  end

  def parse_command("!" <> unknown) do
    {:unknown, String.trim(unknown)}
  end

  def parse_command(no_command) do
    {:no_command, String.trim(no_command)}
  end

  def to_results({:ping, %{msg: msg}}, _ruleset) do
    {msg, "Pong!"}
  end

  def to_results({:avgdmg, %{msg: msg, content: content}}, ruleset) do
    case ruleset.parse_for_avgdmg(content) do
      :nomatch -> {msg, "Failed to parse target string `#{content}`"}
      {:error, err} -> {msg, "Target string parse resulted in error: `#{err}`"}
      parsed -> {msg, "Average damage for `#{content}`:\n`#{ruleset.avgdmg(parsed)}`"}
    end
  end

  def to_results({:help, %{msg: msg}}, _ruleset) do
    {msg, """
    Usage:
    ```
    !ping
      responds with pong
    !avgdmg [some weapon spec] [with (adv|disadv)] vs [some ac]
      calculates the expected average damage for the weapon spec against the given ac
    !help
      this message
    ```
    """
    }
  end
end
