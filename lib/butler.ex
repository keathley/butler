defmodule Butler do
  use Application

  def start(_type, plugins) do
    Butler.Supervisor.start_link(plugins)
  end

  def stop(_) do
    IO.puts "Cheerio"
  end
end
