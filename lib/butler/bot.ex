defmodule Butler.Bot do
  use GenServer

  @adapter Application.get_env(:butler, :adapter)
  @plugins Application.get_env(:butler, :plugins)

  def start_link(event_manager) do
    GenServer.start_link(__MODULE__, {event_manager}, [name: __MODULE__])
  end

  def notify(message) do
    GenServer.cast(__MODULE__, {:notify, message})
  end

  def respond({response, original}) do
    GenServer.cast(__MODULE__, {:respond, response, original})
  end

  def init({manager}) do
    Enum.each(@plugins, fn({handler, state}) ->
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
end

