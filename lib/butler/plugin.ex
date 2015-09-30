defmodule Butler.Plugin do
  @moduledoc """
  Defines a Plugin.
  """

  use Behaviour

  @doc """
  Called for any messages that come through the bot.
  """
  defcallback hear(msg :: String.t, state :: any) ::
              {:noreply, state :: any} |
              {:reply, {:text, String.t}, state :: any} |
              {:reply, {:code, String.t}, state :: any} |
              {:reply, {:quote, String.t}, state :: any}|
              {:reply, String.t, state :: any}

  @doc """
  Called for any messages that starts with the bot's name.
  """
  defcallback respond(msg :: String.t, state :: any) ::
              {:noreply, state :: any} |
              {:reply, {:text, String.t}, state :: any} |
              {:reply, {:code, String.t}, state :: any} |
              {:reply, {:quote, String.t}, state :: any}|
              {:reply, String.t, state :: any}

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @bot_name Application.get_env(:butler, :name)

      use GenEvent

      require Logger

      def handle_event({:message, %{text: text} = original}, state) do
        response = send_response_to_plugin(text, state)
        {:ok, state} = handle_response(response, original)
      end


      defp send_response_to_plugin(text, state) do
        case bot_mentioned?(text) do
          true -> strip_name(text) |> respond(state)
          _    -> hear(text, state)
        end
      end

      defp bot_mentioned?(text) do
        name = @bot_name |> String.downcase
        [first | _] = String.split(text)
        first |> String.downcase |> String.contains?(name)
      end

      defp strip_name(text) do
        [_ | msg] = String.split(text)
        Enum.join(msg, " ")
      end

      defp handle_response({:reply, response, state}, original) do
        Butler.Bot.respond({response, original})
        {:ok, state}
      end

      defp handle_response({:noreply, state}, original), do: {:ok, state}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def hear(_msg, state), do: {:noreply, state}
      def respond(_msg, state), do: {:noreply, state}
    end
  end
end

