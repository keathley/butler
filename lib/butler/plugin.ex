defmodule Butler.Plugin do
  @moduledoc """
  Defines a Plugin.
  """

  # use Behaviour


  # @doc """
  # Called for any messages that come through the bot.
  # """
  # defcallback hear(msg :: String.t, state :: any) ::
  #             {:noreply, state :: any} |
  #             {:reply, {:text, String.t}, state :: any} |
  #             {:reply, {:code, String.t}, state :: any} |
  #             {:reply, {:quote, String.t}, state :: any}|
  #             {:reply, String.t, state :: any}

  # @doc """
  # Called for any messages that starts with the bot's name.
  # """
  # defcallback respond(msg :: String.t, state :: any) ::
  #             {:noreply, state :: any} |
  #             {:reply, {:text, String.t}, state :: any} |
  #             {:reply, {:code, String.t}, state :: any} |
  #             {:reply, {:quote, String.t}, state :: any}|
  #             {:reply, String.t, state :: any}

  @doc false
  defmacro __using__(_opts) do
    quote do
      # @behaviour unquote(__MODULE__)
      import unquote(__MODULE__)

      Module.register_attribute __MODULE__, :handlers, accumulate: true

      @before_compile unquote(__MODULE__)
      @bot_name Application.get_env(:butler, :name)

      require Logger

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
          _   -> call_plugin(handler, text)
        end
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

  defp bots_name_regex do
    {first_char, rest} =
      Application.get_env(:butler, :name)
      |> String.split_at 1
    "@?(?i)#{first_char}(?-i)#{rest}:?"
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
end

