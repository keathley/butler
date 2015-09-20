defmodule Butler.Supervisor do
  use Supervisor

  def start_link(plugins) do
    Supervisor.start_link(__MODULE__, {:ok, plugins})
  end

  @manager Butler.EventManager
  @adapter Application.get_env(:bot, :adapter)

  def init({:ok, plugins}) do
    children = [
      worker(GenEvent, [[name: @manager]]),
      worker(@adapter, []),
      worker(Butler.Bot, [@manager, plugins])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
