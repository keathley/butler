defmodule Butler.Plugin.Responders do
  def text(msg)  when is_binary(msg), do: {:text, msg}
  def code(msg)  when is_binary(msg), do: {:code, msg}
  def emote(msg) when is_binary(msg), do: {:emote, msg}
  @type conn :: %Butler.Message{}

  @spec text(Butler.Message.text) :: Butler.Message.text
  def text(msg) when is_binary(msg), do: {:text, msg}
  def text(msg), do: msg

  @spec code(Butler.Message.text) :: Butler.Message.text
  def code(msg) when is_binary(msg), do: {:code, msg}
  def code(msg), do: msg

  @spec emote(Butler.Message.text) :: Butler.Message.text
  def emote(msg) when is_binary(msg), do: {:emote, msg}
  def emote(msg), do: msg

  @spec reply(conn, String.t) :: nil
  def reply(conn, text) do
    response(conn, text)
    |> Butler.Bot.reply
  end

  @spec say(conn, String.t) :: nil
  def say(conn, text) do
    response(conn, text)
    |> Butler.Bot.say
  end

  defp response(conn, text) do
    %Butler.Response{user: conn.user, channel: conn.channel, text: text}
  end
end
