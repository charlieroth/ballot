defmodule Election.State do
  @type projections :: map()

  @type side_effects :: map()

  @type t :: %Election.State{
          key: Election.key(),
          projections: projections(),
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

  def process_command(
        %Election.State{} = state,
        %Message{key: key, kind: :open_election} = _cmd
      ) do
    event = %Message{
      key: key,
      kind: :election_opened,
      payload: %{}
    }

    {:ok, projections, _side_effects} = handle(key, state.projections, event, state.event_store)
    %{state | event_store: [event | state.event_store], projections: projections}
  end

  def process_command(
        %Election.State{} = state,
        %Message{key: key, kind: :close_election} = _cmd
      ) do
    event = %Message{
      key: key,
      kind: :election_closed,
      payload: %{}
    }

    {:ok, projections, _side_effects} = handle(key, state.projections, event, state.event_store)
    %{state | event_store: [event | state.event_store], projections: projections}
  end

  @spec handle(
          key :: Election.key(),
          projections :: projections(),
          event :: Message.t(),
          event_store :: [Message.t()]
        ) :: {:ok, projections(), side_effects()}
  def handle(_key, projections, %Message{kind: :election_closed} = _event, _event_store) do
    {:ok, projections, %{}}
  end

  def handle(_key, projections, %Message{kind: :election_opened} = _event, _event_store) do
    {:ok, projections, %{}}
  end
end
