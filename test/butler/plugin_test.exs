defmodule Butler.PluginTest do
  use ExUnit.Case, async: true

  defmodule Bot do
    use Butler.Plugin

    def respond("test", state) do
      {:reply, "replying to test", state}
    end

    def hear("hear", state) do
      {:reply, "heard you", state}
    end
  end

  defmodule FakeWebsocketClient do
    def send({:text, json}, socket) do
      {json, socket}
    end
  end

  test "responds to its name" do
    assert Bot.bot_mentioned?("butler you there?")
  end

  test "doesn't respond to other messages" do
    refute Bot.bot_mentioned?("you there?")
  end

  test "parse_message/1 removes bots name" do
    assert Bot.parse_message("butler you there?") == "you there?"
  end

  test "respond/2 defaults to no reply" do
    assert Bot.respond("blah", []) == {:noreply, []}
  end

  test "hear/2 defaults to noreply" do
    assert Bot.hear("meh", []) == {:noreply, []}
  end

  test "send_message/3 sends the json payload" do
    result = Bot.send_message(
      "Test Message",
      "chan",
      %{socket: nil},
      FakeWebsocketClient
    )
    assert result == {
      ~s({"type":"message","text":"Test Message","channel":"chan"}),
      %{socket: nil}
    }
  end
end
