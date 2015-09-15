defmodule Butler.Supervisor do
  use Supervisor

  def start_link(plugins, adapter) do
    Supervisor.start_link(__MODULE__, {:ok, plugins, adapter})
  end

  @manager_name Butler.EventManager

  def init({:ok, plugins, adapter}) do
    children = [
      worker(GenEvent, [[name: @manager_name]]),
      worker(adapter, [@manager_name, plugins, [name: adapter]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
