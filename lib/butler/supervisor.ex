defmodule Butler.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @manager_name Butler.EventManager

  def init(:ok) do
    children = [
      worker(GenEvent, [[name: @manager_name]]),
      worker(Butler.Bot, [@manager_name, [name: Butler.Bot]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
