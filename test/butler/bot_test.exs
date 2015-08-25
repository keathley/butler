defmodule Butler.BotTest do
  use ExUnit.Case, async: true

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  setup do
    {:ok, manager} = GenEvent.start_link
    {:ok, bot} = Butler.Bot.start_link(manager)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, bot: bot}
  end

  test "sends messages to plugins" do
    
  end
end
