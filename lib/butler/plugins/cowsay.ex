defmodule Butler.Plugins.Cowsay do
  use Butler.Plugin

  respond ~r/cowsay (.*)/, [_all, say] do
    {response, 0} = System.cmd("cowsay", [say])
    code("#{response}")
  end
end
