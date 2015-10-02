defmodule <%= mod_name %>.Example do
  use Butler.Plugin

  # TODO - Add some comments with examples of how to bulid plugins
  def respond("example me", state) do
    {:reply, "This is an example response", state}
  end
end
