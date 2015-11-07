defmodule <%= mod_name %>.Example do
  use Butler.Plugin

  @moduledoc """
  replies to the user with an echo
  """
  respond ~r/echo (.*)/, conn, [_all, say] do

    reply conn, "\necho: #{say}"
  end


  @usage """
  listens for a ping and broadcasts a pong
  """
  hear ~r/ping/, conn do
    # ["test"|tests]
    say conn, "-> pong"
  end
end
