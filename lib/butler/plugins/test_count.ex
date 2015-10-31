defmodule Butler.Plugins.TestCount do
  use Butler.Plugin

  respond ~r/test count/, conn do
    # count = Enum.count(tests)
    count = 3
    reply conn, "The count is #{count}"
  end

  hear ~r/test/, conn do
    # ["test"|tests]
    say conn, "I heard some tests"
    say conn, "incrementing..."
  end
end
