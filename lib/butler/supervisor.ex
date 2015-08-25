defmodule Butler.Supervisor do
  use Supervisor

  def start_link(plugins) do
    Supervisor.start_link(__MODULE__, {:ok, plugins})
  end

  @manager_name Butler.EventManager

  def init({:ok, plugins}) do
    children = [
      worker(GenEvent, [[name: @manager_name]]),
      worker(Butler.Bot, [@manager_name, plugins, [name: Butler.Bot]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
