defmodule Butler.Bot do
  @behaviour :websocket_client_handler

  def start_link(opts \\ []) do
    {:ok, json} = Butler.Rtm.start
    url = String.to_char_list(json.url)
    :websocket_client.start_link(url, __MODULE__, json)
  end

  def init(json, socket) do
    slack = %{
      socket: socket,
      me: json.self,
      team: json.team,
      channels: json.channels,
      groups: json.groups,
      users: json.users
    }

    {:ok, slack}
  end

  def websocket_info(:start, _connection, slack) do
    IO.puts "Starting"
    {:ok, slack}
  end

  def websocket_terminate(reason, _connection, slack) do
    IO.puts "Terminated"
    IO.inspect reason
    {:error, slack}
  end

  def websocket_handle({:ping, msg}, _connection, slack) do
    IO.puts "Ping"
    {:reply, {:pong, msg}, slack}
  end

  def websocket_handle({:text, msg}, _connection, slack) do
    message = Poison.Parser.parse!(msg, keys: :atoms)
    handle_message(message, slack)
  end

  def hear("Hello Butler") do
    {:reply, "Yo bitch"}
  end

  def hear("Top of the morning") do
    {:reply, "Get out of here"}
  end

  def hear("cowsay " <> say) do
    
  end

  def hear(_) do
    {:noreply}
  end

  defp handle_message(message = %{type: "message", text: text}, slack) do
    IO.puts "incoming text #{text}"
    case hear(text) do
      {:reply, response} ->
        IO.puts "Handled #{response}"
        {:reply, {:text, encode(response, message.channel)}, slack}
      {:noreply} ->
        IO.puts "Didn't know how to reply to #{text}"
        {:noreply, slack}
    end
  end

  defp handle_message(_message, slack), do: {:ok, slack}

  defp encode(text, channel) do
    Poison.encode!(%{ type: "message", text: text, channel: channel })
  end

  def send_message(text, channel, slack) do
    msg = Poison.encode!(%{ type: "message", text: text, channel: channel })
    :websocket_client.send({:text, msg}, slack.socket)
  end
end
