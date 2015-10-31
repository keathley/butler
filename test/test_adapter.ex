defmodule Butler.Adapters.TestAdapter do
  def start_link(_opts \\ []) do
    {:ok, []}
  end

  def send_message(_response, _original) do
    nil
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}),  do: {:ok, "\n#{msg}"}
  def format_response({:text, msg}),  do: {:ok, "#{msg}"}
  def format_response({:quote, msg}), do: {:ok, ">#{msg}"}
  def format_response(response), do: {:error, response}
end
