defmodule Butler.Adapters.Slack do
  require Logger

  @behaviour :websocket_client_handler

  def start_link(_opts \\ []) do
    {:ok, json} = Butler.Adapters.Slack.Rtm.start
    url = String.to_char_list(json["url"])
    {:ok, pid} = :websocket_client.start_link(url, __MODULE__, json)
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def reply(resp) do
    send(__MODULE__, {:reply, resp})
  end

  def say(resp) do
    send(__MODULE__, {:say, resp})
  end

  # Server callbacks

  def init(json, socket) do
    slack = %{
      socket: socket,
      me: json["self"],
      team: json["team"],
      channels: json["channels"],
      groups: json["groups"],
      users: json["users"]
    }

    {:ok, %{slack: slack}}
  end

  def websocket_info({:reply, resp}, _connection, state) do
    json =
      resp
      |> add_message_type
      |> format_response
      |> mention_user
      |> Poison.encode!

    {:reply, {:text, json}, state}
  end

  def websocket_info({:say, resp}, _connection, state) do
    json =
      resp
      |> add_message_type
      |> format_response
      |> Poison.encode!

    {:reply, {:text, json}, state}
  end

  def websocket_handle({:ping, msg}, _connection, state) do
    {:reply, {:pong, msg}, state}
  end

  def websocket_handle({:text, json}, _connection, state) do
    message = Poison.decode!(json, as: Butler.Message)

    case message do
      %{type: "message"} ->
        message
        |> format_username(state)
        |> Butler.Bot.notify
      _                  ->
        Logger.warn "unhandled message type: #{message.type}"
    end

    {:ok, state}
  end

  def format_username(%Butler.Message{}=msg, state) do
    name =
      state.slack.users
      |> find_by_id(msg.user)
      |> user_name

    %Butler.Message{msg | user: name}
  end

  def find_by_id(users, id) do
    users
    |> Enum.find(fn(user) -> user["id"] == id end)
  end

  def user_name(user) do
    user["name"]
  end

  def websocket_terminate(reason, _connection, state) do
    Logger.error "Terminating because: #{reason}"
    {:error, state}
  end

  defp add_message_type(resp) do
    %Butler.Response{resp | type: "message"}
  end

  def format_response(%Butler.Response{}=resp) do
    text = case resp.text do
      {:code, msg} -> "```#{msg}```"
      {:text, msg} -> "#{msg}"
      {:quote, msg} -> ">#{msg}"
      _ -> resp.text
    end

    %Butler.Response{resp | text: text}
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}), do: "```#{msg}```"
  def format_response({:text, msg}),  do: "#{msg}"
  def format_response({:quote, msg}), do: ">#{msg}"

  defp mention_user(%Butler.Response{} = resp) do
    new_text = "@#{resp.user}: #{resp.text}"
    %Butler.Response{resp | text: new_text}
  end
end
