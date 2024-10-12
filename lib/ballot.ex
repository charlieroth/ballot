defmodule Ballot do
  @moduledoc false

  @spec parse_node(node :: Node.t()) :: %{
          name: String.t(),
          host: String.t(),
          dc: String.t(),
          dc_az: String.t(),
          dc_node: String.t()
        }
  def parse_node(node) do
    node_string = Atom.to_string(node)
    [name, host] = String.split(node_string, "@")
    [dc, dc_az, dc_node] = String.split(name, "-")

    %{
      name: name,
      host: host,
      dc: dc,
      dc_az: dc_az,
      dc_node: dc_node
    }
  end

  @spec is_election_process_running?(election_key :: Election.Key.t()) :: boolean()
  def is_election_process_running?(election_key) do
    election_name = Election.Key.to_name(election_key)

    case Registry.lookup(Ballot.Registry, election_name) do
      [{_pid, _value}] -> true
      [] -> false
    end
  end

  @spec is_current_node(election_node :: Node.t()) :: boolean()
  def is_current_node(election_node) do
    election_node == Node.self()
  end
end
