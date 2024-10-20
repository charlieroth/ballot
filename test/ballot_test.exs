defmodule BallotTest do
  use ExUnit.Case

  describe "parse_node/1" do
    test "correctly parses node name to expected map" do
      assert Ballot.parse_node(:"MI-A-1@localhost") == %Ballot.ClusterNode{
               name: "MI-A-1",
               host: "localhost",
               dc: "MI",
               dc_az: "A",
               dc_node: "1"
             }
    end
  end
end
