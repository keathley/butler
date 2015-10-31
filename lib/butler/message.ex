defmodule Butler.Message do
  @moduledoc """
  The Butler message.

  This module defines a `Butler.Message` struct to hold all of the data for an
  incoming message. This message is passed from adapters to plugins and provides
  all of the necesary information for plugins to respond correctly.
  """
  @adapter Application.get_env(:butler, :adapter)

  @type adapter :: {module, term}
  @type channel :: binary
  @type text    :: binary | nil
  @type type    :: binary
  @type user    :: binary

  @type t :: %__MODULE__{
    adapter: adapter,
    channel: channel,
    text:    text,
    type:    type,
    user:    user
  }

  defstruct adapter: {@adapter, nil},
            channel: nil,
            user: nil,
            text: nil,
            type: nil
end
