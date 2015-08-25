defmodule Butler.Plugins.Cowsay do
  use Butler.Plugin

  def respond("cowsay " <> say, state) do
    {response, 0} = System.cmd("cowsay", [say])
    resp_string = "```#{response}```"

    {:reply, resp_string, state}
  end
end
