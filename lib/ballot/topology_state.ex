defmodule Ballot.TopologyState do
  defstruct [:dcs, :dc_hash_rings, :cluster_hash_ring]

  alias Ballot.TopologyState

  def new(dcs) do
    dc_hash_rings =
      Map.new(dcs, fn dc ->
        hash_ring =
          HashRing.new()
          |> HashRing.add_node("#{dc}-A-1")
          |> HashRing.add_node("#{dc}-A-2")
          |> HashRing.add_node("#{dc}-A-3")
          |> HashRing.add_node("#{dc}-A-4")
          |> HashRing.add_node("#{dc}-B-1")
          |> HashRing.add_node("#{dc}-B-2")
          |> HashRing.add_node("#{dc}-B-3")
          |> HashRing.add_node("#{dc}-B-4")

        {dc, hash_ring}
      end)

    cluster_hash_ring =
      Enum.reduce(dcs, HashRing.new(), fn dc, acc ->
        HashRing.add_node(acc, dc)
      end)

    %TopologyState{
      dcs: dcs,
      dc_hash_rings: dc_hash_rings,
      cluster_hash_ring: cluster_hash_ring
    }
  end

  def get_current(%TopologyState{dc_hash_rings: dc_hash_rings}) do
    dc_hash_rings
  end

  def get_dc_hash_ring(%TopologyState{dc_hash_rings: dc_hash_rings}, dc) do
    Map.get(dc_hash_rings, dc)
  end

  def get_actor_server(
        %TopologyState{dc_hash_rings: dc_hash_rings, cluster_hash_ring: cluster_hash_ring},
        %{id: id, facility: facility}
      ) do
    dc = HashRing.key_to_node(cluster_hash_ring, {id, facility})
    dc_hash_ring = Map.get(dc_hash_rings, dc)
    HashRing.key_to_node(dc_hash_ring, {id, facility})
  end
end
