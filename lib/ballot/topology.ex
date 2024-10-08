defmodule Ballot.Topology do
  use GenServer

  alias Ballot.TopologyState

  def start_link(dcs \\ []) do
    GenServer.start_link(__MODULE__, dcs, name: __MODULE__)
  end

  @doc """
  Get the current topology.
  """
  def get_current() do
    GenServer.call(__MODULE__, :get_current)
  end

  @doc """
  Get the data centers.
  """
  def get_dcs() do
    GenServer.call(__MODULE__, :get_dcs)
  end

  @doc """
  Get the hash ring for a data center.
  """
  def get_dc_hash_ring(dc) do
    GenServer.call(__MODULE__, {:get_dc_hash_ring, dc})
  end

  @doc """
  Get cluster node location for an actor server. 
  """
  def get_actor_server(%{id: _id, facility: _facility} = key) do
    GenServer.call(__MODULE__, {:get_actor_server, key})
  end

  @impl true
  def init(dcs) do
    state = TopologyState.new(dcs)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_current, _from, state) do
    {:reply, TopologyState.get_current(state), state}
  end

  @impl true
  def handle_call(:get_dcs, _from, state) do
    {:reply, state.dcs, state}
  end

  @impl true
  def handle_call({:get_dc_hash_ring, dc}, _from, state) do
    {:reply, TopologyState.get_dc_hash_ring(state, dc), state}
  end

  @impl true
  def handle_call({:get_actor_server, %{id: _id, facility: _facility} = key}, _from, state) do
    {:reply, TopologyState.get_actor_server(state, key), state}
  end
end
