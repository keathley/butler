defmodule Butler.Adapters.Console do
  @behaviour Butler.Adapter

  def start_link do
    import Supervisor.Spec

    children = [
      worker(Task, [__MODULE__, :accept, []])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def reply(resp) do
    resp
    |> format_response
    |> mention_user
    |> IO.puts
  end

  def say(resp) do
    resp
    |> format_response
    |> IO.puts
  end

  def accept do
    text = IO.gets prompt

    text
    |> String.rstrip
    |> new_message
    |> Butler.Bot.notify

    accept
  end

  def format_response(%Butler.Message{text: {:code, msg}}=resp) do
    %Butler.Message{resp | text: "\n#{msg}"}
  end
  def format_response(%Butler.Message{text: {:text, msg}}=resp) do
    %Butler.Message{resp | text: "#{msg}"}
  end
  def format_response(%Butler.Message{text: {:quote, msg}}=resp) do
    %Butler.Message{resp | text: ">#{msg}"}
  end
  def format_response(%Butler.Message{text: text}=resp) when is_binary(text) do
    resp
  end

  defp mention_user(%Butler.Message{user: user, text: text}=resp) do
    %Butler.Message{resp | text: "@#{user}#{text}"}
  end

  defp new_message(text) do
    %Butler.Message{ text: text, channel: "terminal", user: "1337" }
  end

  defp prompt do
    "#{Butler.Bot.name}>"
  end
end
