defmodule Butler.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, {:ok})
  end

  @manager Butler.EventManager
  @adapter Application.get_env(:butler, :adapter)

  def init({:ok}) do
    children = [
      worker(GenEvent, [[name: @manager]]),
      supervisor(Task.Supervisor, [[name: Butler.PluginSupervisor]], restart: :temporary),
      worker(@adapter, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
