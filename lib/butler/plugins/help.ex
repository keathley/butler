defmodule Butler.Plugins.Help do
  @moduledoc """
  Replies with a list of usages for all of the installed plugins.
  """

  use Butler.Plugin

  @usage """
  #{name} help - Returns the helps messages for all the installed plugins
  """
  respond ~r/help/, conn do
    conn
    |> reply usages
  end

  defp usages do
    Butler.Bot.plugins
    |> Enum.map(fn({plugin, _opts}) -> plugin end)
    |> Enum.flat_map(fn(plugin) -> plugin.usage end)
    |> Enum.join
    |> code
  end
end
