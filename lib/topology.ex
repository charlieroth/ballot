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
  Get cluster node location for an actor server. 
  """
  @spec get_actor_server(%{id: String.t(), facility: String.t()}) :: String.t()
  def get_actor_server(%{id: _id, facility: _facility} = key) do
    GenServer.call(__MODULE__, {:get_actor_server, key})
  end

  @impl true
  def init(:ok) do
    :net_kernel.monitor_nodes(true)
    state = Topology.State.new()
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
  def handle_call({:get_actor_server, %{id: _id, facility: _facility} = key}, _from, state) do
    {:reply, Topology.State.get_actor_server(state, key), state}
  end

  @impl true
  def handle_call(_msg, _from, state) do
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(_msg, state) do
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
  def terminate(_reason, _state) do
    Logger.info("[topology] - terminating")
    :ok
  end
end
