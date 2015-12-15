defmodule Butler.Adapters.NullAdapter do
  @behaviour Butler.Adapter

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def reply(_resp) do
    :ok
  end

  def say(_resp) do
    :ok
  end
  
  def format_response(%Butler.Message{}=resp), do: resp
end
