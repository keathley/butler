defmodule Butler.Bot do
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

  def name do
    Application.get_env(:butler, :name) || "butler"
  end

  def plugins do
    Application.get_env(:butler, :plugins)
  end

  def adapter do
    Application.get_env(:butler, :adapter)
  end

  defp notify_plugin({plugin, _opts}, msg) do
    Task.Supervisor.start_child(Butler.PluginSupervisor, plugin, :notify, [msg])
  end
end
