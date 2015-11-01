defmodule Butler.Plugins.TestCount do
  @moduledoc """
  Keeps track of the number of times 'test' has been said in chat.
  """
  use Butler.Plugin

  @usage """
  butler test count - Returns the number of times 'test' has been said
  """
  respond ~r/test count/, conn do
    # count = Enum.count(tests)
    count = 3
    reply conn, "The count is #{count}"
  end

  @usage """
  test - Increments the count
  """
  hear ~r/test/, conn do
    # ["test"|tests]
    say conn, "I heard some tests"
    say conn, "incrementing..."
  end
end
