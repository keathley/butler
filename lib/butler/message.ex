defmodule Butler.Message do
  defstruct type: "", text: "", user: "", channel: ""
end

defmodule Butler.Response do
  @deriving [Poison.Encoder]
  defstruct type: "message", text: "", channel: ""
end

