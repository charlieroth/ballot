defmodule Election do
  use GenServer

  require Logger

  @type key :: %{id: String.t(), facility: String.t()}
  @type projections :: map()
  @type side_effects :: map()
  @type state :: %{
          key: key(),
          event_store: [Message.t()],
          projections: Election.projections()
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
      projections: %{}
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(%Message{kind: :open_election} = cmd, _from, state) do
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
  def handle_call(%Message{kind: :close_election} = cmd, _from, state) do
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

  def handle_command(%Message{kind: :close_election} = _cmd, state) do
    %Message{
      key: state.key,
      kind: :election_closed,
      payload: %{}
    }
  end

  @spec handle_event(
          key :: key(),
          projections :: projections(),
          event :: Message.t(),
          event_store :: [Message.t()]
        ) :: {:ok, projections(), side_effects()}
  def handle_event(_key, projections, %Message{kind: :election_closed} = _event, _event_store) do
    {:ok, projections, %{}}
  end

  def handle_event(_key, projections, %Message{kind: :election_opened} = _event, _event_store) do
    {:ok, projections, %{}}
  end
end
