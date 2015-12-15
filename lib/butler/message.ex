defmodule Butler.Message do
  @moduledoc """
  The Butler message.

  This module defines a `Butler.Message` struct to hold all of the data for an
  incoming message. This message is passed from adapters to plugins and provides
  all of the necesary information for plugins to respond correctly.
  """
  @type text    :: {atom, String.t}
                 | String.t
                 | nil
  @type channel :: binary
  @type type    :: binary
  @type user    :: binary

  @type t :: %__MODULE__{
    channel: channel,
    text:    text,
    type:    type,
    user:    user
  }

  @derive [Poison.Encoder]

  defstruct channel: nil,
            user: nil,
            text: nil,
            type: nil
end

defimpl String.Chars, for: Butler.Message do
  def to_string(%Butler.Message{text: text}) do
    text
  end
end
