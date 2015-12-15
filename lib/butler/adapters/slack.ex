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
    Poison.decode!(json, as: Butler.Message)
    |> handle_message(state)
  end

  @spec handle_message(Butler.Message.t, term) :: :ok
                                                | {:error, term}
  def handle_message(%Butler.Message{type: "message"}=msg, state) do
    unless sent_from_self?(msg, state.slack.me) do
      msg
      |> replace_id_with_botname(state.slack.me)
      |> format_username(state)
      |> Butler.Bot.notify
    end
  end
  def handle_message(%Butler.Message{type: type}, state) do
    Logger.warn "unhandled message type: #{type}"
    {:ok, state}
  end

  def websocket_terminate(reason, _connection, state) do
    Logger.error "Terminating because: #{reason}"
    {:error, state}
  end

  def format_response(%Butler.Message{text: {:code, msg}}=resp) do
    %Butler.Message{resp | text: "```#{msg}```"}
  end
  def format_response(%Butler.Message{text: {:text, msg}}=resp) do
    %Butler.Message{resp | text: "#{msg}"}
  end
  def format_response(%Butler.Message{text: {:quote, msg}}=resp) do
    %Butler.Message{resp | text: ">#{msg}"}
  end
  def format_response(%Butler.Message{text: msg}=resp) when is_binary(msg) do
    resp
  end

  @spec sent_from_self?(Butler.Message.t, term) :: boolean
  defp sent_from_self?(%Butler.Message{user: user}, %{"id" => id}) do
    user == id
  end

  defp replace_id_with_botname(%Butler.Message{text: text}=msg, bot) do
    regex = Regex.compile!("<@#{bot["id"]}>(.*)")
    text = Regex.replace(regex, text, "@#{bot["name"]}\\1")

    %Butler.Message{msg | text: text}
  end

  defp find_by_id(users, id) do
    users
    |> Enum.find(fn(user) -> user["id"] == id end)
  end

  defp format_username(%Butler.Message{user: user}=msg, state) do
    name =
      state.slack.users
      |> find_by_id(user)
      |> user_name

    %Butler.Message{msg | user: name}
  end

  defp user_name(user) do
    user["name"]
  end

  defp add_message_type(resp) do
    %Butler.Message{resp | type: "message"}
  end

  defp mention_user(%Butler.Message{text: text, user: user} = resp) do
    %Butler.Message{resp | text: "@#{user}: #{text}"}
  end
end
