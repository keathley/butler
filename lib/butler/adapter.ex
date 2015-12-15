defmodule Butler.Adapter do
  @moduledoc """
  This module specifies the adapter API for adapters to different chat
  applications.
  """

  @doc """
  Called when the adapter is started. Start any other proccesses that
  are needed for the adapter here
  """
  @callback start_link :: {:ok, term} | :error

  @doc """
  Sends a message back to a specific user on the same channel that the original
  message was posted in.
  """
  @callback reply(Butler.Message.t) :: :ok

  @doc """
  Sends a message back to the channel.
  """
  @callback say(Butler.Message.t) :: :ok

  @doc """
  Formats message text correctly for the specific adapter
  """
  @callback format_response(Butler.Message.t) :: Butler.Message.t
end
