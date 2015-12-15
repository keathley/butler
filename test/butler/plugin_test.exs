defmodule Butler.PluginTest do
  use ExUnit.Case, async: true

  defmodule Bot do
    def say(msg) do
      send self, {:say, msg}
    end

    def reply(msg) do
      send self, {:reply, msg}
    end
  end

  defmodule TestPlugin do
    use Butler.Plugin

    @usage """
    #{name} test - tests the plugin
    """
    respond(~r/test/, conn) do
      say conn, "I heard my name", Bot
    end

    respond(~r/capture (.*)$/, [_all, str], conn) do
      say conn, "I heard #{str}", Bot
    end

    @usage """
    channel test - test channels
    """
    hear(~r/channel test/, %{channel: "testchannel"}=conn) do
      reply conn, "This works", Bot
    end

    hear(~r/channel test/, _conn) do
      # Do nothing
    end

    hear(~r/user test/, %{user: "user"}=conn) do
      reply conn, "is a user", Bot
    end
  end

  test "reply/2 when the bot is mentioned" do
    msg = %Butler.Message{text: "Butler test"}
    TestPlugin.notify(msg)
    assert_received {:say, %Butler.Message{text: "I heard my name"}}
  end

  test "reply/2 captures patterns" do
    text = "Butler capture the test string"
    msg = %Butler.Message{text: text}
    TestPlugin.notify(msg)
    assert_received {:say, %Butler.Message{text: "I heard the test string"}}
  end

  test "can use the bots name" do
    [first | _rest] = TestPlugin.usage
    assert first =~ ~r/Butler test/
  end

  test "multiple usages" do
    count = Enum.count(TestPlugin.usage)
    assert count == 2
  end

  test "matching against channels" do
    msg = %Butler.Message{text: "channel test", channel: "testchannel"}
    TestPlugin.notify(msg)
    assert_received {:reply, %Butler.Message{text: "This works"}}
  end

  test "when channels aren't handled" do
    msg = %Butler.Message{text: "channel test", channel: "otherchannel"}
    TestPlugin.notify(msg)
    refute_received {:reply, %Butler.Message{text: "This works"}}
  end

  test "matching against users" do
    msg = %Butler.Message{text: "user test", user: "user"}
    TestPlugin.notify(msg)
    assert_received {:reply, %Butler.Message{text: "is a user"}}
  end

end
