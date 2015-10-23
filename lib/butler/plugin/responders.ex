defmodule Butler.Plugin.Responders do
  def text(msg)  when is_binary(msg), do: {:text, msg}
  def code(msg)  when is_binary(msg), do: {:code, msg}
  def emote(msg) when is_binary(msg), do: {:emote, msg}

  @type conn :: %Butler.Response{}

  @spec reply(conn, String.t) :: nil
  def reply(conn, text) do
    resp = response(conn, text)
    Butler.Bot.reply(conn, resp)
  end

  @spec say(conn, String.t) :: nil
  def say(conn, text) do
    resp = response(conn, text)
    Butler.Bot.say(conn, resp)
  end

  defp response(conn, text) do
    %Butler.Response{user: conn.user, channel: conn.channel, text: text}
  end
end
