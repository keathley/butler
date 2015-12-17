defmodule Butler.Plugin do
  @moduledoc """
  Plugins give Butler abilities.

  ## Hearing and Responding

  There are 2 ways of listening to incoming messages. Butler can either `hear` a message
  in a room or `respond` to messages addressed to it. Both macros take a regex as their first argument,
  an optional list of regex matches, and then a connection struct. The connection contains all of the data
  about the original message (which channel it came from, who sent it) as well as information about the
  chat environment.

  ```elixir
  defmodule MyPlugin do
    use Butler.Plugin

    @usage "\#{name} test <phrase> - Lets the user know that they got the message"
    respond(~r/test (.*)$/, [_all, phrase], conn) do
      reply conn, "I heard \#{phrase}"
    end

    @usage "lambda - expresses a love for lambdas to the channel"
    hear(~r/lambda/, conn) do
      say conn, "lambda all the things"
    end
  end
  ```


  ## Saying and Replying

  Butler can either reply to the sender of the original message with `reply` or broadcast a
  message back to the channel with `say`.

  ## Formatting responses

  Its often the case that you'll need to format a response, for instance marking a response as code.
  This is easy to do with Butler's formatters. These formatters are based on the specific adapter being used.

  ```elixir
    respond ~r/codeme (.*)$/, [_all, phrase], conn do
      reply conn, code(phrase) # returns the message as code
    end

    respond ~r/textme (.*)$/, [_all, phrase], conn do
      reply conn, text(phrase) # returns the message as text
    end

    respond ~r/emoteme (.*)$/, [_all, phrase], conn do
      reply conn, emote(phrase) # returns the message as an emote
    end
  ```
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      import Butler.Plugin.Responders
      import Butler.Bot, only: [name: 0]

      Module.register_attribute __MODULE__, :responders, accumulate: true
      Module.register_attribute __MODULE__, :hearers, accumulate: true
      Module.register_attribute __MODULE__, :usage, accumulate: true

      @before_compile unquote(__MODULE__)

      def call_plugin({fn_name, regex}, msg) do
        apply(__MODULE__, fn_name, [msg, Regex.run(regex, msg.text)])
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def usage do
        @usage
        |> Enum.map(fn(usage) -> usage end)
        |> Enum.reverse
      end

      def notify(msg) do
        if handler = find_handler(msg) do
          call_plugin(handler, msg)
        end
      end

      defp find_handler(msg) do
        Enum.find(handlers, &(matches_regex?(&1, msg)))
      end

      defp matches_regex?({_func, regex}, msg) do
        Regex.match?(regex, msg.text)
      end

      defp handlers do
        @responders ++ @hearers
      end
    end
  end

  defmacro respond({:sigil_r, _, pattern}, captures, conn,  do: block) do
    fn_name = name(pattern)
    regex = respond_regex(pattern) |> Macro.escape

    quote do
      @responders {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)(unquote(conn), unquote(captures)) do
        unquote(block)
      end
    end
  end

  defmacro respond({:sigil_r, _, pattern}, conn, do: block) do
    fn_name = name(pattern)
    regex = respond_regex(pattern) |> Macro.escape

    quote do
      @responders {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)(unquote(conn), [_all]) do
        unquote(block)
      end
    end
  end

  defmacro hear({:sigil_r, _, pattern}=regex, conn, do: block) do
    fn_name = name(pattern)

    quote do
      @hearers {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)(unquote(conn), [_all]) do
        unquote(block)
      end
    end
  end

  defmacro hear({:sigil_r, _, pattern}=regex, captures, conn, do: block) do
    fn_name = name(pattern)

    quote do
      @hearers {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)(unquote(conn), unquote(captures)) do
        unquote(block)
      end
    end
  end

  defp source([{:<<>>, _, [string]}, []]) do
    string
  end

  defp name(pattern) do
    pattern
    |> source
    |> String.to_atom
  end

  defp respond_regex(pattern) do
    text = source(pattern)
    ~r"#{bots_name_regex} #{text}"
  end

  defp bots_name do
    Butler.Bot.name
  end

  defp bots_name_regex do
    {first_char, rest} = bots_name |> String.split_at 1
    "@?(?i)#{first_char}(?-i)#{rest}:?"
  end
end
