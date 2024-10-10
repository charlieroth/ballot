defmodule Topology.State do
  @type t :: %__MODULE__{
          dc_hash_rings: %{String.t() => HashRing.t()},
          cluster_hash_ring: HashRing.t()
        }

  defstruct [:dc_hash_rings, :cluster_hash_ring]

  @doc """
  Create a new topology state.
  """
  @spec new() :: t()
  def new() do
    %Topology.State{
      dc_hash_rings: %{},
      cluster_hash_ring: HashRing.new()
    }
  end

  @doc """
  Get the data centers in the topology.
  """
  @spec get_dcs(t()) :: [String.t()]
  def get_dcs(%Topology.State{dc_hash_rings: dc_hash_rings}) do
    Map.keys(dc_hash_rings)
  end

  @doc """
  Get the current set of data center`HashRing`s in the topology.
  """
  @spec get_current(t()) :: %{String.t() => HashRing.t()}
  def get_current(%Topology.State{dc_hash_rings: dc_hash_rings}) do
    dc_hash_rings
  end

  @doc """
  Get the `HashRing` for a given data center.
  """
  @spec get_dc_hash_ring(t(), String.t()) :: HashRing.t()
  def get_dc_hash_ring(%Topology.State{dc_hash_rings: dc_hash_rings}, dc) do
    Map.get(dc_hash_rings, dc)
  end

  @doc """
  Get the actor server for a given actor key
  """
  @spec get_actor_server(t(), %{id: String.t(), facility: String.t()}) :: String.t()
  def get_actor_server(
        %Topology.State{dc_hash_rings: dc_hash_rings, cluster_hash_ring: cluster_hash_ring},
        %{id: id, facility: facility}
      ) do
    dc = HashRing.key_to_node(cluster_hash_ring, {id, facility})
    dc_hash_ring = Map.get(dc_hash_rings, dc)
    HashRing.key_to_node(dc_hash_ring, {id, facility})
  end

  @doc """
  Add a node to the topology.
  """
  @spec add_node(t(), atom()) :: t()
  def add_node(%Topology.State{} = state, node) do
    %{dc: dc, name: name} = Ballot.parse_node(node)
    dc_hash_ring = Map.get(state.dc_hash_rings, dc, HashRing.new())
    dc_hash_ring = HashRing.add_node(dc_hash_ring, name)
    new_dc_hash_rings = Map.put(state.dc_hash_rings, dc, dc_hash_ring)

    %Topology.State{
      state
      | dc_hash_rings: new_dc_hash_rings,
        cluster_hash_ring: HashRing.add_node(state.cluster_hash_ring, dc)
    }
  end

  @doc """
  Remove a node from the topology.
  """
  @spec remove_node(t(), atom()) :: t()
  def remove_node(%Topology.State{} = state, node) do
    %{dc: dc, name: name} = Ballot.parse_node(node)
    dc_hash_ring = Map.get(state.dc_hash_rings, dc)
    dc_hash_ring = HashRing.remove_node(dc_hash_ring, name)
    dc_hash_ring_nodes = HashRing.nodes(dc_hash_ring)

    if length(dc_hash_ring_nodes) == 0 do
      dc_hash_rings = Map.delete(state.dc_hash_rings, dc)
      cluster_hash_ring = HashRing.remove_node(state.cluster_hash_ring, dc)

      %Topology.State{
        state
        | dc_hash_rings: dc_hash_rings,
          cluster_hash_ring: cluster_hash_ring
      }
    else
      dc_hash_rings = Map.put(state.dc_hash_rings, dc, dc_hash_ring)

      %Topology.State{
        state
        | dc_hash_rings: dc_hash_rings
      }
    end
  end
end