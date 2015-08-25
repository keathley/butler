defmodule Butler.Bot do
  @behaviour :websocket_client_handler

  def start_link(event_manager, opts \\ []) do
    {:ok, json} = Butler.Rtm.start
    url = String.to_char_list(json.url)
    :websocket_client.start_link(url, __MODULE__, {json, event_manager})
  end

  def init({json, events}, socket) do
    slack = %{
      socket: socket,
      me: json.self,
      team: json.team,
      channels: json.channels,
      groups: json.groups,
      users: json.users
    }

    GenEvent.add_handler(events, Butler.Plugin, [])

    {:ok, %{slack: slack, events: events}}
  end

  def websocket_info(:start, _connection, state) do
    IO.puts "Starting"
    {:ok, state}
  end

  def websocket_terminate(reason, _connection, state) do
    IO.puts "Terminated"
    IO.inspect reason
    {:error, state}
  end

  def websocket_handle({:ping, msg}, _connection, state) do
    IO.puts "Ping"
    {:reply, {:pong, msg}, state}
  end

  def websocket_handle({:text, msg}, _connection, state) do
    message = Poison.Parser.parse!(msg, keys: :atoms)
    handle_message(message, state)
  end

  defp handle_message(message = %{type: "message", text: text}, state) do
    IO.puts "incoming text #{text}"
    GenEvent.notify(state.events, {:message, text, message.channel, state.slack})
    {:ok, state}
    # case Butler.Plugin.hear(text) do
    #   {:reply, response} ->
    #     IO.puts "Handled #{text} with #{response}"
    #     {:reply, {:text, encode(response, message.channel)}, state}
    #   {:noreply} ->
    #     IO.puts "Ignoring #{text} with :ok}"
    #     {:ok, state}
    # end
  end

  defp handle_message(_message, state), do: {:ok, state}

  defp encode(text, channel) do
    Poison.encode!(%{ type: "message", text: text, channel: channel })
  end

  def send_message(text, channel, socket) do
    msg = Poison.encode!(%{ type: "message", text: text, channel: channel })
    :websocket_client.send({:text, msg}, socket)
  end
end
