defmodule Butler.PluginTest do
  use ExSpec, async: true

  defmodule TestPlugin do
    use Butler.Plugin

    respond(~r/test (.*)/, [_all, text]) do
      reply("You sent me #{text}")
    end

    respond ~r/snausage me/ do
      reply("snausages")
    end

    respond ~r/no reply/ do
    end

    hear ~r/can you hear me/ do
      reply("I heard that")
    end

    hear ~r/Oh, (.*)/, [_all, capture] do
      reply("heh, #{capture}")
    end

    hear ~r/hear no reply/ do
    end
  end

  test "respond/2 when the message doesn't start with bots name" do
    assert TestPlugin.notify("some message") == {:noreply}
  end

  test "respond/2 does not reply by default" do
    assert TestPlugin.notify("butler no reply") == {:noreply}
  end

  test "respond/1 when the message starts with bots name" do
    response = TestPlugin.notify("butler snausage me")
    assert response == {:reply, {:text, "snausages"}}
  end

  test "respond/2 returns capture groups" do
    response = TestPlugin.notify("butler test this message")
    assert response == {:reply, {:text, "You sent me this message"}}
  end

  test "respond/1 responds when the name is capitalized" do
    response = TestPlugin.notify("Butler snausage me")
    assert response == {:reply, {:text, "snausages"}}
  end

  test "respond/1 responds when the name is 'mentioned'" do
    response = TestPlugin.notify("@Butler: snausage me")
    assert response == {:reply, {:text, "snausages"}}
  end

  test "hear/2 listens for any messages" do
    response = TestPlugin.notify("can you hear me")
    assert response == {:reply, {:text, "I heard that"}}
  end

  test "hear/1 does not reply by default" do
    assert TestPlugin.notify("hear no reply") == {:noreply}
  end

  test "hear/2 returns any capture groups" do
    response = TestPlugin.notify("Oh, snausages")
    assert response == {:reply, {:text, "heh, snausages"}}
  end

  test "text/1 replies as text" do
    assert TestPlugin.text("test text") == {:reply, {:text, "test text"}}
  end

  test "code/1 replies as text" do
    assert TestPlugin.code("test text") == {:reply, {:code, "test text"}}
  end

  test "emote/1 replies as text" do
    assert TestPlugin.emote("test text") == {:reply, {:emote, "test text"}}
  end
end

