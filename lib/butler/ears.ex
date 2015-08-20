defmodule Butler.Ears do

  def hear("Hello Butler") do
    {:reply, "Yo bitch"}
  end

  def hear("cowsay " <> say) do
    {response, 0} = System.cmd("cowsay", [say])
    resp_string = "```#{response}```"
    {:reply, resp_string}
  end

  def hear(_) do
    {:noreply}
  end
end
