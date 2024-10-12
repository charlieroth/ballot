defmodule Message do
  @type message_kind :: :open_election | :election_opened | :close_election | :election_closed

  @type t :: %{
          key: Election.key(),
          kind: message_kind(),
          payload: map()
        }

  @enforce_keys [:key, :kind, :payload]

  defstruct [:key, :kind, :payload]
end
