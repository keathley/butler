defmodule Butler.Plugin do
  @moduledoc """
  Defines a Plugin.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      import Butler.Plugin.Responders

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

  defmacro respond({:sigil_r, _, pattern}, conn, captures, do: block) do
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

  defmacro hear({:sigil_r, _, pattern}=regex, conn, captures, do: block) do
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
