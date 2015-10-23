defmodule Butler.Bot do
  @adapter Application.get_env(:butler, :adapter)
  @plugins Application.get_env(:butler, :plugins)

  def notify(msg) do
    @plugins
    |> Enum.each(fn(plugin) -> notify_plugin(plugin, msg) end)
  end

  def reply(resp) do
    @adapter.reply(resp)
  end

  def say(resp) do
    @adapter.say(resp)
  end

  defp notify_plugin({plugin, _opts}, msg) do
    Task.Supervisor.start_child(Butler.PluginSupervisor, plugin, :notify, [msg])
  end
end
