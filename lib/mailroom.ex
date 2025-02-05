defmodule Mailroom do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def dispatch(%Message{} = msg) do
    GenServer.cast(__MODULE__, {:dispatch, msg})
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(%Message{kind: :start_reader, key: key} = _cmd, _from, state) do
    {:ok, _election_pid} = Election.Supervisor.start_child(key)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.info("[mailroom:call] - unknown call message received: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast({:dispatch, %Message{key: key} = cmd}, state) do
    Logger.info("[mailroom:cast] - received cmd: #{inspect(cmd)}")

    # --- Command Dispatch Protocol ---
    # If the intended receipient is a local `Election` process, 
    election_node = Topology.get_election_node(key)
    is_current_node = Ballot.is_current_node(election_node)

    if is_current_node do
      is_election_process_running = Ballot.is_election_process_running?(key)

      # If the local `Election` process is already running,
      if is_election_process_running do
        # Send command to local `Election` process
        :ok = Election.process_command(cmd)
      else
        # If the local `Election` process is not running,
        # - 1. Start local `Election` process (writer)
        # - 2. Start 1 remote `Election` process in other availability zone (reader)
        # - 2. State 2 remote `Election` processes in other data centers (readers)
        # - Send command to local `Election` process
        {:ok, _election_pid} = Election.Supervisor.start_child(key)
        :ok = Election.process_command(cmd)
      end
    else
      # If the intended receipient is a remote `Election` process,
      # - Get the intended receipient's node
      # - Send command to remote `Mailroom` process
      :ok = GenServer.cast({Mailroom, election_node}, {:dispatch, cmd})
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.info("[mailroom:cast] - unknown cast message received: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("[mailroom:info] - unknown info message received: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("[mailroom:terminate] - terminating: #{inspect(reason)}")
    :ok
  end
end
