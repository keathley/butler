defmodule Butler.Adapters.Slack do
  require Logger

  @behaviour :websocket_client_handler

  def start_link(_opts \\ []) do
    {:ok, json} = Butler.Adapters.Slack.Rtm.start
    url = String.to_char_list(json.url)
    {:ok, pid} = :websocket_client.start_link(url, __MODULE__, json)
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def send_message(response, original) do
    send(__MODULE__, {:respond, response, original})
  end

  # Server callbacks

  def init(json, socket) do
    slack = %{
      socket: socket,
      me: json.self,
      team: json.team,
      channels: json.channels,
      groups: json.groups,
      users: json.users
    }

    {:ok, %{slack: slack}}
  end

  def websocket_info({:respond, text, original}, _connection, state) do
    case format_response(text) do
      {:ok, text} ->
        response = %{text: text, channel: original.channel, type: "message"}
        json = Poison.encode!(response)
        {:reply, {:text, json}, state}
      {:error, _} ->
        Logger.error "Unknown response type"
        {:noreply, state}
    end
  end

  def websocket_handle({:ping, msg}, _connection, state) do
    {:reply, {:pong, msg}, state}
  end

  def websocket_handle({:text, json}, _connection, state) do
    message = Poison.decode!(json, as: Butler.Message)

    case message do
      %{type: "message"} ->
        Butler.Bot.notify(message)
      _                  ->
        Logger.warn "unhandled message type: #{message.type}"
    end

    {:ok, state}
  end

  def websocket_terminate(reason, _connection, state) do
    Logger.error "Terminating because: #{reason}"
    {:error, state}
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}),  do: {:ok, "```#{msg}```"}
  def format_response({:text, msg}),  do: {:ok, "#{msg}"}
  def format_response({:quote, msg}), do: {:ok, ">#{msg}"}
  def format_response(response), do: {:error, response}
end

