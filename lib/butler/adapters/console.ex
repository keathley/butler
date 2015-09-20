defmodule Butler.Adapters.Console do
  require Logger

  def start_link(event_manager, plugins, _opts \\ []) do
    Enum.each(plugins, fn {handler, state} ->
      GenEvent.add_handler(event_manager, handler, state)
    end)

    {:ok, pid} = Task.start_link(fn -> loop(event_manager) end)

    Process.register(pid, :adapter)

    {:ok, pid}
  end

  def send_message(response, _original) do
    case format_response(response) do
      {:ok, text} ->
        IO.puts text
      {:error, _} ->
        Logger.error "Unknown response type: #{response.type}"
    end
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}),  do: {:ok, "```#{msg}```"}
  def format_response({:text, msg}),  do: {:ok, "#{msg}"}
  def format_response({:quote, msg}), do: {:ok, ">#{msg}"}
  def format_response(response), do: {:error, response}

  # Server Callbacks

  defp loop(events) do
    text = IO.gets prompt
    message = %Butler.Message{ text: text, channel: "terminal", user: "1337" }

    GenEvent.notify(events, {:message, message})

    loop(events)
  end

  defp prompt do
    "butler>"
  end
end

