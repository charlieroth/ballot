defmodule Ballot do
  @moduledoc false

  @spec via(key :: Election.key()) :: tuple()
  def via(key) do
    {:via}
    |> Tuple.append(Registry)
    |> Tuple.append({Ballot.Registry, key})
  end

  @spec parse_node(node :: Node.t()) :: Ballot.ClusterNode.t()
  def parse_node(node) do
    node_string = Atom.to_string(node)
    [name, host] = String.split(node_string, "@")
    [dc, dc_az, dc_node] = String.split(name, "-")

    %Ballot.ClusterNode{
      name: name,
      host: host,
      dc: dc,
      dc_az: dc_az,
      dc_node: dc_node
    }
  end

  @spec is_election_process_running?(key :: Election.key()) :: boolean()
  def is_election_process_running?(key) do
    case Registry.lookup(Ballot.Registry, key) do
      [{_pid, _value}] -> true
      [] -> false
    end
  end

  @spec is_current_node(node :: Node.t()) :: boolean()
  def is_current_node(node) do
    node == Node.self()
  end
end
