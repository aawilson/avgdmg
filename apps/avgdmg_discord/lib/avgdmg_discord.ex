defmodule AvgdmgDiscord do
  @moduledoc """
  Basically ripped from Nostrum.Consumer, but defines a producer_consumer rather than
  a consumer
  """
  require Logger
  use GenStage

  # Client

  def start_link(opts \\ []) do
    GenStage.start_link(__MODULE__, :ok, opts)
  end

  # Server

  @doc false
  def init(:ok) do
    producers =
      CacheStageRegistry
      |> Registry.lookup(:pids)
      |> Enum.map(fn {pid, _value} -> pid end)

    {:producer_consumer, :ok, subscribe_to: producers}
  end

  @doc false
  def handle_events(events, _from, state) do
    commands = Enum.filter(events, &type_filter/1)
    |> Enum.flat_map(&content_filter/1)

    {:noreply, commands, state}
  end

  defp type_filter({:MESSAGE_CREATE, _, _}), do: true
  defp type_filter(_), do: false

  defp content_filter({_, {msg}, _}) do
    case AvgdmgStage.Commands.parse_command(msg.content) do
      {:unknown, unknown} ->
        Logger.error fn -> "unknown command: #{unknown}" end
        []
      {:no_command, _} ->
        []
      :error ->
        Logger.error fn -> "some error happened in content filter" end
        []
      {cmd, content} ->
        [{cmd, %{content: content, msg: msg}}]
    end
  end
end
