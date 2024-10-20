defmodule Topology.State do
  @type t :: %__MODULE__{
          dc_az_hash_rings: %{String.t() => HashRing.t()},
          dc_hash_rings: %{String.t() => HashRing.t()},
          cluster_hash_ring: HashRing.t()
        }

  @enforce_keys [:dc_hash_rings, :cluster_hash_ring, :dc_az_hash_rings]

  defstruct [:dc_hash_rings, :cluster_hash_ring, :dc_az_hash_rings]

  require Logger

  @doc """
  Create a new topology state.
  """
  @spec new() :: t()
  def new() do
    %Topology.State{
      dc_az_hash_rings: %{},
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
  Given a `Topology.State` and `Election.Key`, get the cluster node for
  an associated `Election` process
  """
  @spec get_election_node(t(), Election.key()) :: Node.t()
  def get_election_node(
        %Topology.State{dc_hash_rings: dc_hash_rings, cluster_hash_ring: cluster_hash_ring},
        key
      ) do
    dc = HashRing.key_to_node(cluster_hash_ring, key)
    dc_hash_ring = Map.get(dc_hash_rings, dc)
    HashRing.key_to_node(dc_hash_ring, key)
  end

  @spec get_reader_election_nodes(t(), Election.key()) :: [Node.t()]
  def get_reader_election_nodes(
        %Topology.State{dc_hash_rings: dc_hash_rings, cluster_hash_ring: cluster_hash_ring},
        key
      ) do
    # Get reader node from same data center, other availability zone
    # Get reader nodes, one from each data center
  end

  @doc """
  Add a `Node` to the `Topology.State`.
  """
  @spec add_node(t(), Node.t()) :: t()
  def add_node(%Topology.State{} = state, node) do
    cluster_node = Ballot.parse_node(node)
    dc_az = Ballot.ClusterNode.get_dc_az(cluster_node)

    # Update `dc_az_hash_rings`
    dc_az_hash_ring = Map.get(state.dc_az_hash_rings, dc_az, HashRing.new())
    dc_az_hash_ring = HashRing.add_node(dc_az_hash_ring, node)
    new_dc_az_hash_rings = Map.put(state.dc_az_hash_rings, dc_az, dc_az_hash_ring)

    # Update `dc_hash_rings`
    dc_hash_ring = Map.get(state.dc_hash_rings, cluster_node.dc, HashRing.new())
    dc_hash_ring = HashRing.add_node(dc_hash_ring, node)
    new_dc_hash_rings = Map.put(state.dc_hash_rings, cluster_node.dc, dc_hash_ring)

    # Update `cluster_hash_ring`
    new_cluster_hash_ring = HashRing.add_node(state.cluster_hash_ring, cluster_node.dc)

    %Topology.State{
      state
      | dc_az_hash_rings: new_dc_az_hash_rings,
        dc_hash_rings: new_dc_hash_rings,
        cluster_hash_ring: new_cluster_hash_ring
    }
  end

  @doc """
  Remove a `Node` from the `Topology.State`.
  """
  @spec remove_node(t(), Node.t()) :: t()
  def remove_node(%Topology.State{} = state, node) do
    cluster_node = Ballot.parse_node(node)
    dc_az = Ballot.ClusterNode.get_dc_az(cluster_node)

    dc_az_hash_ring = Map.get(state.dc_az_hash_rings, dc_az)
    dc_az_hash_ring = HashRing.remove_node(dc_az_hash_ring, node)

    dc_hash_ring = Map.get(state.dc_hash_rings, cluster_node.dc)
    dc_hash_ring = HashRing.remove_node(dc_hash_ring, node)

    dc_az_hash_ring_nodes = HashRing.nodes(dc_az_hash_ring)
    dc_hash_ring_nodes = HashRing.nodes(dc_hash_ring)

    if length(dc_az_hash_ring_nodes) == 0 and length(dc_hash_ring_nodes) == 0 do
      dc_az = Ballot.ClusterNode.get_dc_az(cluster_node)
      new_dc_az_hash_rings = Map.delete(state.dc_az_hash_rings, dc_az)
      new_dc_hash_rings = Map.delete(state.dc_hash_rings, cluster_node.dc)
      new_cluster_hash_ring = HashRing.remove_node(state.cluster_hash_ring, cluster_node.dc)

      %Topology.State{
        state
        | dc_az_hash_rings: new_dc_az_hash_rings,
          dc_hash_rings: new_dc_hash_rings,
          cluster_hash_ring: new_cluster_hash_ring
      }
    else
      dc_az = Ballot.ClusterNode.get_dc_az(cluster_node)
      new_dc_az_hash_rings = Map.put(state.dc_az_hash_rings, dc_az, dc_az_hash_ring)
      new_dc_hash_rings = Map.put(state.dc_hash_rings, cluster_node.dc, dc_hash_ring)

      %Topology.State{
        state
        | dc_az_hash_rings: new_dc_az_hash_rings,
          dc_hash_rings: new_dc_hash_rings
      }
    end
  end
end
