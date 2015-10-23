defmodule Butler.Response do
  @moduledoc """
  The Butler response.
  """

  @type channel :: binary
  @type text    :: binary | nil
  @type user    :: binary

  @type t :: %__MODULE__{
    channel: channel,
    text:    text,
    user:    user
  }

  defstruct channel: nil,
            text: nil,
            user: nil
end
