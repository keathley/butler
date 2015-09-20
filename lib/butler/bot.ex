defmodule Butler.Bot do
  use GenServer

  @adapter Application.get_env(:bot, :adapter)

  def start_link(event_manager, plugins) do
    GenServer.start_link(__MODULE__, {event_manager, plugins}, [name: __MODULE__])
  end

  def notify(message) do
    GenServer.cast(__MODULE__, {:notify, message})
  end

  def respond({response, original}) do
    GenServer.cast(__MODULE__, {:respond, response, original})
  end

  def init({manager, plugins}) do
    Enum.each(plugins, fn({handler, state}) ->
      GenEvent.add_mon_handler(manager, handler, state)
    end)
    {:ok, {manager}}
  end

  def handle_cast({:respond, response, original}, state) do
    @adapter.send_message(response, original)
    {:noreply, state}
  end

  def handle_cast({:notify, message}, {manager}=state) do
    GenEvent.notify(manager, {:message, message})
    {:noreply, state}
  end

  defp adapter do
  end
end

