defmodule Ballot.TopologyServer do
  use GenServer

  alias Ballot.Topology

  def start_link(dc_list \\ []) do
    GenServer.start_link(__MODULE__, dc_list, name: __MODULE__)
  end

  def get_dc_hash_ring(dc) do
    GenServer.call(__MODULE__, {:get_dc_hash_ring, dc})
  end

  def get_actor_server(%{id: _id, facility: _facility} = key) do
    GenServer.call(__MODULE__, {:get_actor_server, key})
  end

  def init(dc_list) do
    topology = Topology.new(dc_list)
    {:ok, topology}
  end

  def handle_call({:get_dc_hash_ring, dc}, _from, topology) do
    hash_ring = Topology.get_dc_hash_ring(topology, dc)
    {:reply, hash_ring, topology}
  end

  def handle_call({:get_actor_server, %{id: id, facility: facility}}, _from, topology) do
    actor_server = Topology.get_actor_server(topology, %{id: id, facility: facility})
    {:reply, actor_server, topology}
  end
end
