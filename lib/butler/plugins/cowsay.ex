defmodule Butler.Plugins.Cowsay do
  use Butler.Plugin

  respond ~r/cowsay (.*)/, conn, [_all, say] do
    {response, 0} = System.cmd("cowsay", [say])

    reply conn, code("#{response}")
  end
end
