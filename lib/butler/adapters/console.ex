defmodule Butler.Adapters.Console do
  use Butler.Adapter

  @bot_name Application.get_env(:butler, :name)

  def start_link do
    import Supervisor.Spec

    children = [
      worker(Task, [__MODULE__, :accept, []])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def reply(resp) do
    IO.puts mention_user(resp.user) <> format_response(resp.text)
  end

  def say(resp) do
    IO.puts format_response(resp.text)
  end

  def accept do
    text = IO.gets prompt

    text
    |> String.rstrip
    |> new_message
    |> Butler.Bot.notify

    accept
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}),  do: "\n#{msg}"
  def format_response({:text, msg}),  do: "#{msg}"
  def format_response({:quote, msg}), do: ">#{msg}"
  def format_response(_), do: ""

  defp mention_user(user) do
    "@#{user}: "
  end

  defp new_message(text) do
    %Butler.Message{ text: text, channel: "terminal", user: "1337" }
  end

  defp prompt do
    "#{@bot_name}>"
  end
end
