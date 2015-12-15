defmodule Butler.Bot do
  @type bot_name :: String.t
  @type bot_id   :: String.t

  def notify(msg) do
    plugins
    |> Enum.each(fn(plugin) -> notify_plugin(plugin, msg) end)
  end

  def reply(resp) do
    adapter.reply(resp)
  end

  def say(resp) do
    adapter.say(resp)
  end

  @spec name :: bot_name
  def name do
    Application.get_env(:butler, :name) || "butler"
  end

  @spec plugins :: list(Butler.Plugin.t)
  def plugins do
    Application.get_env(:butler, :plugins) || []
  end

  @spec adapter :: module
  def adapter do
    Application.get_env(:butler, :adapter)
  end

  defp notify_plugin({plugin, _opts}, msg) do
    Task.Supervisor.start_child(Butler.PluginSupervisor, plugin, :notify, [msg])
  end
end
