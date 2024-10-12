defmodule Election.State do
  @type t :: %Election.State{
          key: Election.Key.t(),
          projections: map(),
          event_store: list()
        }

  defstruct [:key, :projections, :event_store]

  @spec new(key :: Election.key()) :: t()
  def new(key) do
    %Election.State{
      key: key,
      projections: %{},
      event_store: []
    }
  end

  def process_command(%Election.State{} = state, %Message{key: key, kind: :open_election} = _msg) do
    event = %Message{
      key: key,
      kind: :election_opened,
      payload: %{}
    }

    %{state | event_store: [event | state.event_store]}
  end

  def process_command(%Election.State{} = state, %Message{key: key, kind: :close_election} = _msg) do
    event = %Message{
      key: key,
      kind: :election_closed,
      payload: %{}
    }

    %{state | event_store: [event | state.event_store]}
  end
end
