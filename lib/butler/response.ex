defmodule Butler.Response do
  @moduledoc """
  The Butler response.
  """

  @type channel :: binary
  @type text    :: binary | nil
  @type user    :: binary
  @type type    :: binary

  @type t :: %__MODULE__{
    channel: channel,
    text:    text,
    user:    user,
    type:    type
  }

  @derive [Poison.Encoder]

  defstruct channel: nil,
            text: nil,
            user: nil,
            type: nil
end

