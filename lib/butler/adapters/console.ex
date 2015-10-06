defmodule Butler.Adapters.Console do
  require Logger

  @bot_name Application.get_env(:butler, :name)

  def start_link(_opts \\ []) do
    import Supervisor.Spec

    children = [
      worker(Task, [__MODULE__, :accept, []])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def send_message({:reply, response}, _original) do
    case format_response(response) do
      {:ok, text} ->
        IO.puts text
      {:error, _} ->
        Logger.error "Unknown response type: #{response.type}"
    end
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
  def format_response({:code, msg}),  do: {:ok, "\n#{msg}"}
  def format_response({:text, msg}),  do: {:ok, "#{msg}"}
  def format_response({:quote, msg}), do: {:ok, ">#{msg}"}
  def format_response(response), do: {:error, response}

  defp new_message(text) do
    %Butler.Message{ text: text, channel: "terminal", user: "1337" }
  end

  defp prompt do
    "#{@bot_name}>"
  end
end

