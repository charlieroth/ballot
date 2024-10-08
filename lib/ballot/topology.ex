defmodule Ballot.Topology do
  def get_dc_hash_ring(topology, dc) do
    Map.get(topology, dc)
  end

  def get_actor_server(topology, %{id: id, facility: facility}) do
    datacenter = Ballot.get_datacenter()
    dc_hash_ring = Map.get(topology, datacenter)
    HashRing.key_to_node(dc_hash_ring, {id, facility})
  end

  def new(dc_list) do
    Map.new(dc_list, fn dc ->
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
  end
end
