defmodule Butler.Ears do
  def hear("cowsay " <> say) do
    {response, 0} = System.cmd("cowsay", [say])
    resp_string = "```#{response}```"
    {:reply, resp_string}
  end

  def hear(_) do
    {:noreply}
  end
end
