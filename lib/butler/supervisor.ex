defmodule Butler.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, {:ok})
  end

  def init({:ok}) do
    children = [
      supervisor(Task.Supervisor, [[name: Butler.PluginSupervisor]], restart: :temporary),
      worker(adapter, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp adapter do
    Application.get_env(:butler, :adapter)
  end
end
