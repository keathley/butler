defmodule Butler.Plugin.Responders do
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

  @spec reply(conn, Butler.Message.text) :: nil
  def reply(conn, text, bot \\ Butler.Bot) do
    response(conn, text)
    |> bot.reply
  end

  @spec say(conn, Butler.Message.text) :: nil
  def say(conn, text, bot \\ Butler.Bot) do
    response(conn, text)
    |> bot.say
  end

  @spec response(conn, Butler.Message.text) :: Butler.Message.t
  defp response(conn, text) do
    %Butler.Message{conn | text: text}
  end
end
