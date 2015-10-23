defmodule Butler.Adapters.NullAdapter do
  def start_link(_opts \\ []) do
    {:ok, []}
  end

  def reply(_resp) do
    nil
  end

  def say(_resp) do
    nil
  end

  def format_response(msg) when is_binary(msg) do
    format_response({:text, msg})
  end
  def format_response({:code, msg}),  do: "\n#{msg}"
  def format_response({:text, msg}),  do: "#{msg}"
  def format_response({:quote, msg}), do: ">#{msg}"
  def format_response(_), do: ""
end
