defmodule TestTopologyState do
  use ExUnit.Case

  setup do
    topology = %Topology.State{
      cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI", "IN", "IL", "OH"]),
      dc_hash_rings: %{
        "MI" =>
          HashRing.add_nodes(HashRing.new(), [
            :"MI-A-1@localhost",
            :"MI-B-1@localhost",
            :"MI-B-4@localhost"
          ]),
        "IN" => HashRing.add_node(HashRing.new(), :"IN-B-2@localhost"),
        "IL" => HashRing.add_node(HashRing.new(), :"IL-B-3@localhost"),
        "OH" => HashRing.add_node(HashRing.new(), :"OH-A-4@localhost")
      }
    }

    {:ok, topology: topology}
  end

  describe "add_node/2" do
    test "correctly adds a single node to the topology" do
      topology = Topology.State.new() |> Topology.State.add_node(:"MI-A-1@localhost")

      assert topology == %Topology.State{
               dc_hash_rings: %{
                 "MI" => HashRing.add_nodes(HashRing.new(), [:"MI-A-1@localhost"])
               },
               cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI"])
             }
    end

    test "correctly adds many nodes to the topology" do
      topology = Topology.State.add_node(Topology.State.new(), :"MI-A-1@localhost")

      expected_toplogy = %Topology.State{
        dc_hash_rings: %{
          "MI" => HashRing.add_nodes(HashRing.new(), [:"MI-A-1@localhost"])
        },
        cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI"])
      }

      assert HashRing.nodes(topology.cluster_hash_ring) ==
               HashRing.nodes(expected_toplogy.cluster_hash_ring)

      Enum.each(expected_toplogy.dc_hash_rings, fn {dc, hash_ring} ->
        assert HashRing.nodes(topology.dc_hash_rings[dc]) == HashRing.nodes(hash_ring)
      end)

      topology = Topology.State.add_node(topology, :"IN-A-1@localhost")

      expected_toplogy = %Topology.State{
        dc_hash_rings: %{
          "MI" => HashRing.add_nodes(HashRing.new(), [:"MI-A-1@localhost"]),
          "IN" => HashRing.add_nodes(HashRing.new(), [:"IN-A-1@localhost"])
        },
        cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI", "IN"])
      }

      assert HashRing.nodes(topology.cluster_hash_ring) ==
               HashRing.nodes(expected_toplogy.cluster_hash_ring)

      Enum.each(expected_toplogy.dc_hash_rings, fn {dc, hash_ring} ->
        assert HashRing.nodes(topology.dc_hash_rings[dc]) == HashRing.nodes(hash_ring)
      end)

      topology = Topology.State.add_node(topology, :"IL-A-1@localhost")

      expected_toplogy = %Topology.State{
        dc_hash_rings: %{
          "MI" => HashRing.add_nodes(HashRing.new(), [:"MI-A-1@localhost"]),
          "IN" => HashRing.add_nodes(HashRing.new(), [:"IN-A-1@localhost"]),
          "IL" => HashRing.add_nodes(HashRing.new(), [:"IL-A-1@localhost"])
        },
        cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI", "IN", "IL"])
      }

      assert HashRing.nodes(topology.cluster_hash_ring) ==
               HashRing.nodes(expected_toplogy.cluster_hash_ring)

      Enum.each(expected_toplogy.dc_hash_rings, fn {dc, hash_ring} ->
        assert HashRing.nodes(topology.dc_hash_rings[dc]) == HashRing.nodes(hash_ring)
      end)
    end
  end

  describe "remove_node/2" do
    test "when removing last node in a dc, removes the dc from the topology", %{
      topology: topology
    } do
      topology = Topology.State.remove_node(topology, :"IN-B-2@localhost")

      expected_toplogy = %Topology.State{
        cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI", "IL", "OH"]),
        dc_hash_rings: %{
          "MI" =>
            HashRing.add_nodes(HashRing.new(), [
              :"MI-A-1@localhost",
              :"MI-B-1@localhost",
              :"MI-B-4@localhost"
            ]),
          "IL" => HashRing.add_node(HashRing.new(), :"IL-B-3@localhost"),
          "OH" => HashRing.add_node(HashRing.new(), :"OH-A-4@localhost")
        }
      }

      assert HashRing.nodes(topology.cluster_hash_ring) ==
               HashRing.nodes(expected_toplogy.cluster_hash_ring)

      Enum.each(expected_toplogy.dc_hash_rings, fn {dc, hash_ring} ->
        assert HashRing.nodes(topology.dc_hash_rings[dc]) == HashRing.nodes(hash_ring)
      end)
    end

    test "removes a node from the topology", %{topology: topology} do
      topology = Topology.State.remove_node(topology, :"MI-A-1@localhost")

      expected_toplogy = %Topology.State{
        cluster_hash_ring: HashRing.add_nodes(HashRing.new(), ["MI", "IN", "IL", "OH"]),
        dc_hash_rings: %{
          "MI" => HashRing.add_nodes(HashRing.new(), [:"MI-B-1@localhost", :"MI-B-4@localhost"]),
          "IN" => HashRing.add_node(HashRing.new(), :"IN-B-2@localhost"),
          "IL" => HashRing.add_node(HashRing.new(), :"IL-B-3@localhost"),
          "OH" => HashRing.add_node(HashRing.new(), :"OH-A-4@localhost")
        }
      }

      assert HashRing.nodes(topology.cluster_hash_ring) ==
               HashRing.nodes(expected_toplogy.cluster_hash_ring)

      Enum.each(expected_toplogy.dc_hash_rings, fn {dc, hash_ring} ->
        assert HashRing.nodes(topology.dc_hash_rings[dc]) == HashRing.nodes(hash_ring)
      end)
    end
  end

  describe "get_dcs/1" do
    test "returns the data centers", %{topology: topology} do
      dcs = Topology.State.get_dcs(topology)
      assert Enum.member?(dcs, "MI") == true
      assert Enum.member?(dcs, "IN") == true
      assert Enum.member?(dcs, "IL") == true
      assert Enum.member?(dcs, "OH") == true
    end
  end

  describe "get_current/1" do
    test "returns the current dc_hash_rings", %{topology: topology} do
      current = Topology.State.get_current(topology)

      assert current == %{
               "MI" =>
                 HashRing.add_nodes(HashRing.new(), [
                   :"MI-A-1@localhost",
                   :"MI-B-1@localhost",
                   :"MI-B-4@localhost"
                 ]),
               "IN" => HashRing.add_node(HashRing.new(), :"IN-B-2@localhost"),
               "IL" => HashRing.add_node(HashRing.new(), :"IL-B-3@localhost"),
               "OH" => HashRing.add_node(HashRing.new(), :"OH-A-4@localhost")
             }
    end
  end

  describe "get_dc_hash_ring/2" do
    test "returns the dc_hash_ring for a given data center", %{topology: topology} do
      dc_hash_ring = Topology.State.get_dc_hash_ring(topology, "MI")

      assert dc_hash_ring ==
               HashRing.add_nodes(HashRing.new(), [
                 :"MI-A-1@localhost",
                 :"MI-B-1@localhost",
                 :"MI-B-4@localhost"
               ])
    end
  end

  describe "get_election_node/2" do
    test "in the event of a node partition, a new node is selected for the actor", %{
      topology: topology
    } do
      election_key = %Election.Key{id: "1001", facility: "VC-123"}
      prev_election_node = Topology.State.get_election_node(topology, election_key)
      topology = Topology.State.remove_node(topology, prev_election_node)
      new_election_node = Topology.State.get_election_node(topology, election_key)
      assert new_election_node != prev_election_node
    end
  end
end
