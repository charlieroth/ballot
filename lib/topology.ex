defmodule Topology do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Get the current topology.
  """
  @spec get_current() :: TopologyState.t()
  def get_current() do
    GenServer.call(__MODULE__, :get_current)
  end

  @doc """
  Get the data centers.
  """
  @spec get_dcs() :: [String.t()]
  def get_dcs() do
    GenServer.call(__MODULE__, :get_dcs)
  end

  @doc """
  Get the hash ring for a data center.
  """
  @spec get_dc_hash_ring(String.t()) :: HashRing.t()
  def get_dc_hash_ring(dc) do
    GenServer.call(__MODULE__, {:get_dc_hash_ring, dc})
  end

  @doc """
  Given an `Election.Key`, get cluster node location for an election process
  """
  @spec get_election_node(key :: Election.key()) :: Node.t()
  def get_election_node(key) do
    GenServer.call(__MODULE__, {:get_election_node, key})
  end

  @doc """
  """
  @spec get_reader_election_nodes(key :: Election.key()) :: [Node.t()]
  def get_reader_election_nodes(key) do
    GenServer.call(__MODULE__, {:get_reader_election_nodes, key})
  end

  @impl true
  def init(:ok) do
    :net_kernel.monitor_nodes(true)
    nodes = [Node.self() | Node.list()]

    state =
      Enum.reduce(nodes, Topology.State.new(), fn node, state ->
        Topology.State.add_node(state, node)
      end)

    {:ok, state}
  end

  @impl true
  def handle_call(:get_current, _from, state) do
    {:reply, Topology.State.get_current(state), state}
  end

  @impl true
  def handle_call(:get_dcs, _from, state) do
    {:reply, state.dcs, state}
  end

  @impl true
  def handle_call({:get_dc_hash_ring, dc}, _from, state) do
    {:reply, Topology.State.get_dc_hash_ring(state, dc), state}
  end

  @impl true
  def handle_call({:get_election_node, key}, _from, state) do
    {:reply, Topology.State.get_election_node(state, key), state}
  end

  @impl true
  def handle_call({:get_reader_election_nodes, key}, _from, state) do
    {:reply, Topology.State.get_reader_election_nodes(state, key), state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.info("[topology:call] - received unknown message: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.info("[topology:cast] - received unknown message: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    Logger.info("[topology:info] - node up: #{inspect(node)}")
    new_state = Topology.State.add_node(state, node)
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:nodedown, node}, state) do
    Logger.info("[topology:info] - node down: #{inspect(node)}")
    new_state = Topology.State.remove_node(state, node)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("[topology:info] - received unknown message: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("[topology:terminate] - terminating: #{inspect(reason)}")
    :ok
  end
end
