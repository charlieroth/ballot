defmodule Message do
  @type t :: %{
          key: Election.key(),
          kind: atom(),
          payload: map()
        }

  @enforce_keys [:key, :kind, :payload]

  defstruct [:key, :kind, :payload]
end
