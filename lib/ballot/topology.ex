defmodule Ballot.Topology do
  @doc """
  The Topology module is the solution to the problem of
  a globally consistent process registry. Globally consistent
  process registries are very expensive so we use a topology
  built on top of libring to provide a consistent process registry
  using a consistent hashing algorithm. Therefore we have consensus
  via topology and not via a global process registry.

  The topology is a map of datacenters to hash rings. Each hash ring is a
  libring HashRing.t() struct. The keys of the hash ring are the IDs of the
  nodes in the datacenter
  """
  use GenServer

  @spec get_current() :: %{required(String.t()) => HashRing.t()}
  def get_current() do
    GenServer.call(__MODULE__, {:get_current})
  end

  @spec get_dcs() :: [String.t()]
  def get_dcs() do
    GenServer.call(__MODULE__, {:get_dcs})
  end

  @spec get_dc_hash_ring(String.t()) :: HashRing.t() | nil
  def get_dc_hash_ring(dc) do
    GenServer.call(__MODULE__, {:get_dc_hash_ring, dc})
  end

  @spec get_actor_server(%{required(:id) => String.t(), required(:zone) => String.t()}) ::
          String.t() | {:error, String.t()}
  def get_actor_server(%{id: _actor_id, zone: _zone} = key) do
    GenServer.call(__MODULE__, {:get_actor_server, key})
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    topology = %{
      "MI" =>
        HashRing.new()
        |> HashRing.add_nodes([
          ["MI-A-1", "MI-A-2", "MI-A-3", "MI-A-4", "MI-B-1", "MI-B-2", "MI-B-3", "MI-B-4"]
        ])
    }

    {:ok, topology}
  end

  @impl true
  def handle_call({:get_current}, _from, topology) do
    {:reply, topology, topology}
  end

  @impl true
  def handle_call({:get_dcs}, _from, topology) do
    {:reply, Map.keys(topology), topology}
  end

  @impl true
  def handle_call({:get_dc_hash_ring, dc}, _from, topology) do
    {:reply, Map.get(topology, dc), topology}
  end

  @impl true
  def handle_call({:get_actor_server, %{id: id, zone: _zone}}, _from, topology) do
    {:reply, Map.get(topology, id), topology}
  end
end
