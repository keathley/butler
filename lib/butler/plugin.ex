defmodule Butler.Plugin do
  @moduledoc """
  Defines a Plugin.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute __MODULE__, :handlers, accumulate: true

      @before_compile unquote(__MODULE__)

      def text(msg)  when is_binary(msg), do: reply({:text, msg})
      def code(msg)  when is_binary(msg), do: reply({:code, msg})
      def emote(msg) when is_binary(msg), do: reply({:emote, msg})

      def reply(msg) when is_binary(msg), do: reply({:text, msg})
      def reply({:text, _text}=msg),  do: {:reply, msg}
      def reply({:code, _text}=msg),  do: {:reply, msg}
      def reply({:emote, _text}=msg), do: {:reply, msg}

      def call_plugin({fn_name, regex}, text) do
        apply(__MODULE__, fn_name, [Regex.run(regex, text)])
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def notify(text) when is_binary(text) do
        notify({:message, %{text: text}})
      end

      def notify({:message, %{text: text}}) do
        handler = Enum.find @handlers, fn({_func, regex}) ->
          Regex.match?(regex, text)
        end
        case handler do
          nil -> {:noreply}
          _   -> call_plugin(handler, text) || {:noreply}
        end
      end
    end
  end

  defmacro respond({:sigil_r, _, pattern}, captures, do: block) do
    fn_name = name(pattern)
    regex = respond_regex(pattern) |> Macro.escape

    quote do
      @handlers {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)(unquote(captures)) do
        unquote(block)
      end
    end
  end

  defmacro respond({:sigil_r, _, pattern}, do: block) do
    fn_name = name(pattern)
    regex = respond_regex(pattern) |> Macro.escape

    quote do
      @handlers {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)([_all]) do
        unquote(block)
      end
    end
  end

  defmacro hear({:sigil_r, _, pattern}=regex, do: block) do
    fn_name = name(pattern)

    quote do
      @handlers {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)([_all]) do
        unquote(block)
      end
    end
  end

  defmacro hear({:sigil_r, _, pattern}=regex, captures, do: block) do
    fn_name = name(pattern)

    quote do
      @handlers {unquote(fn_name), unquote(regex)}
      def unquote(fn_name)(unquote(captures)) do
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
    Application.get_env(:butler, :name)
  end

  defp bots_name_regex do
    {first_char, rest} = bots_name |> String.split_at 1
    "@?(?i)#{first_char}(?-i)#{rest}:?"
  end

end

