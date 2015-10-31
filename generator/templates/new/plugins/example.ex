defmodule <%= mod_name %>.Example do
  use Butler.Plugin

  respond(~r/example me/) do
    reply "This is an example response"
  end

  hear(~r/examples/) do
    say "I heard some examples"
  end
end
