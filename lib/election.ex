defmodule Election do
  use GenServer

  require Logger

  @type key :: %{id: String.t(), facility: String.t()}
  @type projections :: map()
  @type side_effects :: map()
  @type state :: %{
          key: key(),
          projections: projections(),
          event_store: [Message.t()]
        }

  def start_link(key) do
    GenServer.start_link(__MODULE__, key, name: Ballot.via(key))
  end

  def get_state(key) do
    GenServer.call(Ballot.via(key), :get_state)
  end

  def process_command(%Message{key: key} = cmd) do
    GenServer.call(Ballot.via(key), cmd)
  end

  @impl true
  def init(key) do
    state = %{
      key: key,
      event_store: [],
      projections: %{
        status: :idle,
        casted_ballots: 0,
        validated_ballots: 0,
        invalidated_ballots: 0
      }
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(%Message{} = cmd, _from, state) do
    Logger.info("[election:call] - cmd received: #{inspect(cmd)}")
    event = handle_command(cmd, state)

    {:ok, projections, _side_effects} =
      handle_event(state.key, state.projections, event, state.event_store)

    new_state =
      state
      |> Map.put(:event_store, [event | state.event_store])
      |> Map.put(:projections, projections)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.info("[election:call] - unknown call: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.info("[election:cast] - unknown cast: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("[election:info] - unknown info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("[election:terminate] - terminating: #{inspect(reason)}")
    :ok
  end

  @spec handle_command(cmd :: Message.t(), state :: state()) :: Message.t()
  def handle_command(%Message{kind: :open_election} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :election_opened,
      payload: %{}
    }
  end

  @spec handle_command(cmd :: Message.t(), state :: state()) :: Message.t()
  def handle_command(%Message{kind: :cast_ballot} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :ballot_casted,
      payload: %{}
    }
  end

  @spec handle_command(cmd :: Message.t(), state :: state()) :: Message.t()
  def handle_command(%Message{kind: :validate_ballot} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :ballot_validated,
      payload: %{}
    }
  end

  @spec handle_command(cmd :: Message.t(), state :: state()) :: Message.t()
  def handle_command(%Message{kind: :invalidate_ballot} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :ballot_invalidated,
      payload: %{}
    }
  end

  def handle_command(%Message{kind: :close_election} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :election_closed,
      payload: %{}
    }
  end

  def handle_command(%Message{kind: :validate_election} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :election_validated,
      payload: %{}
    }
  end

  def handle_command(%Message{kind: :invalidate_election} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :election_invalidated,
      payload: %{}
    }
  end

  @spec handle_event(
          key :: key(),
          projections :: projections(),
          event :: Message.t(),
          event_store :: [Message.t()]
        ) :: {:ok, projections(), side_effects()}
  def handle_event(_key, projections, %Message{kind: :election_opened} = _event, _event_store) do
    new_projections = Map.update!(projections, :status, fn _status -> :open end)
    {:ok, new_projections, %{}}
  end

  def handle_event(_key, projections, %Message{kind: :ballot_casted} = _event, _event_store) do
    new_projections =
      Map.update!(projections, :casted_ballots, fn casted_ballots ->
        casted_ballots + 1
      end)

    {:ok, new_projections, %{}}
  end

  def handle_event(_key, projections, %Message{kind: :ballot_validated} = _event, _event_store) do
    new_projections =
      Map.update!(projections, :validated_ballots, fn validated_ballots ->
        validated_ballots + 1
      end)

    {:ok, new_projections, %{}}
  end

  def handle_event(_key, projections, %Message{kind: :ballot_invalidated} = _event, _event_store) do
    new_projections =
      Map.update!(projections, :invalidated_ballots, fn invalidated_ballots ->
        invalidated_ballots + 1
      end)

    {:ok, new_projections, %{}}
  end

  def handle_event(_key, projections, %Message{kind: :election_closed} = _event, _event_store) do
    new_projections = Map.update!(projections, :status, fn _status -> :closed end)
    {:ok, new_projections, %{}}
  end

  def handle_event(_key, projections, %Message{kind: :election_validated} = _event, _event_store) do
    new_projections = Map.update!(projections, :status, fn _status -> :valid end)
    {:ok, new_projections, %{}}
  end

  def handle_event(
        _key,
        projections,
        %Message{kind: :election_invalidated} = _event,
        _event_store
      ) do
    new_projections = Map.update!(projections, :status, fn _status -> :invalid end)
    {:ok, new_projections, %{}}
  end
end
