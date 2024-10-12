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
  def handle_call(msg, _from, state) do
    Logger.info("[mailroom:call] - unknown call message received: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast({:dispatch, %Message{key: key} = msg}, state) do
    Logger.info("[mailroom:cast] - received msg: #{inspect(msg)}")

    # --- Command Dispatch Protocol ---
    # If the intended receipient is a local `Election` process, 
    election_node = Topology.get_election_node(key)
    is_current_node = Ballot.is_current_node(election_node)

    if is_current_node do
      is_election_process_running = Ballot.is_election_process_running?(key)

      # If the local `Election` process is already running,
      if is_election_process_running do
        # Send command to local `Election` process
        :ok = Election.process_msg(msg)
      else
        # If the local `Election` process is not running,
        # - Start local `Election` process
        # - Send command to local `Election` process
        {:ok, _election_pid} = Election.Supervisor.start_child(key)
        :ok = Election.process_msg(msg)
      end
    else
      # If the intended receipient is a remote `Election` process,
      # - Get the intended receipient's node
      # - Send command to remote `Mailroom` process
      :ok = GenServer.cast({Mailroom, election_node}, {:dispatch, msg})
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
