defmodule Butler.Adapters.Slack do
  require Logger

  def start_link(event_manager, plugins, _opts \\ []) do
  end

  def send_message(response, _original) do
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}),  do: {:ok, "```#{msg}```"}
  def format_response({:text, msg}),  do: {:ok, "#{msg}"}
  def format_response({:quote, msg}), do: {:ok, ">#{msg}"}
  def format_response(response), do: {:error, response}
end

