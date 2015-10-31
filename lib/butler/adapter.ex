defmodule Butler.Adapter do
  @moduledoc """
  This module specifies the adapter API for adapters to different chat
  applications.
  """

  use Behaviour

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      require Logger
    end
  end

  @doc """
  Called when the adapter is started. Start any other proccesses that
  are needed for the adapter here
  """
  defcallback start_link :: {:ok, term} | :error

  @doc """
  Sends a message back to a specific user on the same channel that the original
  message was posted in.
  """
  defcallback reply(Butler.Response.t) :: :ok

  @doc """
  Sends a message back to the channel.
  """
  defcallback say(Butler.Respose.t) :: :ok

  @doc """
  Formats message text correctly for the specific adapter
  """
  defcallback format_response({:atom, String.t}) :: String.t
end
