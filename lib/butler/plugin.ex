defmodule Butler.Plugin do
  use GenEvent

  @bot_name Application.get_env(:bot, :name)

  def handle_event({:message, text, channel, slack}, state) do
    if bot_mentioned?(text) do
      parse_message(text) |> respond(state) |> handle_response(channel, slack)
    else
      hear(text, state) |> handle_response(channel, slack)
    end
  end

  defp handle_response({:noreply, state}, _channel, _slack), do: {:ok, state}

  defp handle_response({:reply, message, state}, channel, slack) do
    send_message(message, channel, slack.socket)
    {:ok, state}
  end

  defp bot_mentioned?(text) do
    name = @bot_name |> String.downcase
    [first | _] = String.split(text)
    first |> String.downcase |> String.contains?(name)
  end

  defp parse_message(text) do
    [_ | msg] = String.split(text)
    Enum.join(msg, " ")
  end

  def respond("cowsay " <> say, state) do
    {response, 0} = System.cmd("cowsay", [say])
    resp_string = "```#{response}```"

    {:reply, resp_string, state}
  end

  def respond("test count", state) do
    count = Enum.count(state)
    {:reply, "The count is #{count}", state}
  end

  def hear("test", state) do
    {:noreply, ["test"|state]}
  end

  def hear(_msg, state), do: {:noreply, state}

  def respond(_msg, state), do: {:noreply, state}

  defp send_message(text, channel, socket) do
    msg = Poison.encode!(%{ type: "message", text: text, channel: channel })
    :websocket_client.send({:text, msg}, socket)
  end
end
