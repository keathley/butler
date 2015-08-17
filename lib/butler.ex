defmodule Butler do
  use Application

  def start(_type, _args) do
    IO.puts "Starting"
    Butler.Supervisor.start_link
  end

  def stop(_) do
    IO.puts "Cheerio"
  end
end
