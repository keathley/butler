defmodule <%= mod_name %>.Example do
  use Butler.Plugin

  respond(~r/example me/, conn) do
    reply conn, "This is an example response"
  end

  hear(~r/examples/, conn) do
    say conn, "I heard some examples"
  end
end
