defmodule Butler do
  use Application

  def start(_type, [plugins, adapter]) do
    Butler.Supervisor.start_link(plugins, adapter)
  end

  def stop(_) do
    IO.puts "Cheerio"
  end
end
