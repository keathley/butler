defmodule Butler.PluginTest do
  use ExSpec, async: true

  defmodule TestPlugin do
    use Butler.Plugin

    respond(~r/test (.*)/, [_all, text]) do
      {:reply, "You sent me #{text}"}
    end

    respond ~r/snausage me/ do
      {:reply, "snausages"}
    end
  end

  test "respond/2 when the message doesn't start with bots name" do
    assert TestPlugin.notify("some message") == {:noreply}
  end

  test "respond/2 when the message starts with bots name" do
    assert TestPlugin.notify("butler snausage me") == {:reply, "snausages"}
  end

  test "respond/2 returns capture groups" do
    assert TestPlugin.notify("butler test this message") == {:reply, "You sent me this message"}
  end

  test "respond/2 responds when the name is capitalized" do
    assert TestPlugin.notify("Butler snausage me") == {:reply, "snausages"}
  end

  test "respond/2 responds when the name is 'mentioned'" do
    assert TestPlugin.notify("@Butler: snausage me") == {:reply, "snausages"}
  end
end
