defmodule Butler.Adapters.Console do
  @name Application.get_env(:bot, :name)

  def start_link do
    loop_acceptor
  end

  def loop_acceptor do
    read |> evaluate

    loop_acceptor
  end

  defp read do
    IO.gets prompt
  end

  defp evaluate(msg) do
    Butler.Bot.respond(msg)
  end

  defp print(output) do
    IO.puts output
  end

  def prompt do
    "#{@name}>"
  end
end
