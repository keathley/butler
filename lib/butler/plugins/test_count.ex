defmodule Butler.Plugins.TestCount do
  use Butler.Plugin

  def respond("test count", tests) do
    count = Enum.count(tests)
    {:reply, "The count is #{count}", tests}
  end

  def hear("test", tests) do
    {:noreply, ["test"|tests]}
  end
end
