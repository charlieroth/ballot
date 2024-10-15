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
    Logger.debug("[election:call] - cmd received: #{inspect(cmd)}")

    with {:ok, event} <- handle_command(cmd, state),
         {:ok, projections, _side_effects} <-
           handle_event(state.key, state.projections, event, state.event_store) do
      new_state =
        state
        |> Map.put(:event_store, [event | state.event_store])
        |> Map.put(:projections, projections)

      {:reply, :ok, new_state}
    else
      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.warning("[election:call] - unknown call: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.warning("[election:cast] - unknown cast: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.warning("[election:info] - unknown info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warning("[election:terminate] - terminating: #{inspect(reason)}")
    :ok
  end

  @spec handle_command(cmd :: Message.t(), state :: state()) ::
          {:ok, Message.t()} | {:error, atom()}
  def handle_command(%Message{kind: :open_election} = cmd, state) do
    with true <- can_open_election?(state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :election_opened,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_open_election}
    end
  end

  def handle_command(%Message{kind: :close_election} = cmd, state) do
    with true <- can_close_election?(state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :election_closed,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_close_election}
    end
  end

  def handle_command(%Message{kind: :validate_election} = cmd, state) do
    with true <- can_validate_election?(state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :election_validated,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_validate_election}
    end
  end

  def handle_command(%Message{kind: :invalidate_election} = cmd, state) do
    with true <- can_invalidate_election?(state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :election_invalidated,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_invalidate_election}
    end
  end

  def handle_command(%Message{kind: :cast_ballot} = cmd, state) do
    with true <- can_cast_ballot?(cmd, state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :ballot_casted,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_cast_ballot}
    end
  end

  def handle_command(%Message{kind: :validate_ballot} = cmd, state) do
    with true <- can_validate_ballot?(cmd, state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :ballot_validated,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_validate_ballot}
    end
  end

  def handle_command(%Message{kind: :invalidate_ballot} = cmd, state) do
    with true <- can_invalidate_ballot?(cmd, state) do
      {:ok,
       %Message{
         key: state.key,
         kind: :ballot_invalidated,
         payload: cmd.payload
       }}
    else
      _ -> {:error, :failed_to_invalidate_ballot}
    end
  end

  @spec can_open_election?(state :: state()) :: boolean()
  def can_open_election?(state) do
    state.projections.status == :idle or state.projections.status == :invalid
  end

  @spec can_close_election?(state :: state()) :: boolean()
  def can_close_election?(state) do
    state.projections.status == :open
  end

  @spec can_validate_election?(state :: state()) :: boolean()
  def can_validate_election?(state) do
    state.projections.status == :closed
  end

  @spec can_invalidate_election?(state :: state()) :: boolean()
  def can_invalidate_election?(state) do
    state.projections.status == :closed
  end

  @spec can_cast_ballot?(cmd :: Message.t(), state :: state()) :: boolean()
  def can_cast_ballot?(
        %Message{kind: :cast_ballot, payload: payload},
        state
      ) do
    election_is_open = state.projections.status == :open

    contains_casted_ballot_with_same_signature =
      state.event_store
      |> Enum.filter(fn event ->
        event.kind == :ballot_casted
      end)
      |> Enum.any?(fn event ->
        event.payload.voter_signature == payload.voter_signature
      end)

    election_is_open and not contains_casted_ballot_with_same_signature
  end

  @spec can_validate_ballot?(cmd :: Message.t(), state :: state()) :: boolean()
  def can_validate_ballot?(
        %Message{kind: :validate_ballot, payload: payload},
        state
      ) do
    election_is_closed = state.projections.status == :closed

    contains_casted_ballot_with_same_signature =
      state.event_store
      |> Enum.filter(fn event ->
        event.kind == :ballot_casted
      end)
      |> Enum.any?(fn event ->
        event.payload.voter_signature == payload.voter_signature
      end)

    election_is_closed and contains_casted_ballot_with_same_signature
  end

  @spec can_invalidate_ballot?(cmd :: Message.t(), state :: state()) :: boolean()
  def can_invalidate_ballot?(
        %Message{kind: :invalidate_ballot, payload: payload},
        state
      ) do
    election_is_closed = state.projections.status == :closed

    contains_casted_ballot_with_same_signature =
      state.event_store
      |> Enum.filter(fn event ->
        event.kind == :ballot_casted
      end)
      |> Enum.any?(fn event ->
        event.payload.voter_signature == payload.voter_signature
      end)

    election_is_closed and contains_casted_ballot_with_same_signature
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

  def handle_event(_key, projections, event, _event_store) do
    Logger.warning("[election:handle_event] - unknown event: #{inspect(event)}")
    {:ok, projections, %{}}
  end
end
