defmodule Butler.Adapters.Slack do
  @behaviour Butler.Adapter
  @behaviour :websocket_client_handler

  import Logger

  def start_link do
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
        unless sent_from_self?(message, state) do
          message
          |> replace_id_with_botname(state.slack.me)
          |> format_username(state)
          |> Butler.Bot.notify
        end
        _                ->
        Logger.warn "unhandled message type: #{message.type}"
    end

    {:ok, state}
  end

  def websocket_terminate(reason, _connection, state) do
    Logger.error "Terminating because: #{reason}"
    {:error, state}
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

  defp sent_from_self?(message, state) do
    message.user == state.slack.me["id"]
  end

  defp replace_id_with_botname(%Butler.Message{}=msg, bot) do
    regex = Regex.compile!("<@#{bot["id"]}>(.*)")
    text = Regex.replace(regex, msg.text, "@#{bot["name"]}\\1")

    %Butler.Message{msg | text: text}
  end

  defp find_by_id(users, id) do
    users
    |> Enum.find(fn(user) -> user["id"] == id end)
  end

  defp format_username(%Butler.Message{}=msg, state) do
    name =
      state.slack.users
      |> find_by_id(msg.user)
      |> user_name

    %Butler.Message{msg | user: name}
  end

  defp user_name(user) do
    user["name"]
  end

  defp add_message_type(resp) do
    %Butler.Response{resp | type: "message"}
  end

  defp mention_user(%Butler.Response{} = resp) do
    new_text = "@#{resp.user}: #{resp.text}"
    %Butler.Response{resp | text: new_text}
  end
end
