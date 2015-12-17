defmodule Butler do
  @moduledoc ~S"""
  Butler is a life betterment robot.

  He is split into two main groups:

    * `Butler.Adapter` - adapters allow butler to communicate with other
      protocols and communications platforms.

    * `Butler.Plugin` - plugins are what empower butler. They provide an api
      to respond to specific commands and perform actions and replies.

  ## Adapters

  `Butler.Adapter` is a generic behaviour that allows Butler to support
  multiple chat platforms. There are two officialy supported adapters:

  * `Butler.Adapters.Console` - used for local development.
  * `Butler.Adapters.Slack` - for the slack chat platform.

  You can read more about developing adapters in `Butler.Adapter`.

  ## Plugins

  `Butler.Plugin` provides an api for developers to add functionality to
  Butler. Plugins listen to events emitted by Butler and can choose to respond
  or not. Here is an example plugin:

```elixir
  defmodule MyPlugin do
    use Butler.Plugin

    @usage "#{name} test <phrase> - Lets the user know that they got the message"
    respond(~r/test (.*)$/, [_all, phrase], conn) do
      reply conn, "I heard #{phrase}"
    end

    @usage "lambda - expresses a love for lambdas to the channel"
    hear(~r/lambda/, conn) do
      say conn, "lambda all the things"
    end
  end
```

  If you want to read more about creating your own plugins in `Butler.Plugin`.
  """

  use Application

  @doc """
  Starts Butler.
  """
  def start(_type, _opts \\ []) do
    Butler.Supervisor.start_link()
  end

  @doc """
  Stops Butler.
  """
  def stop(_) do
    IO.puts "Cheerio"
  end
end
