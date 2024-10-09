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

  def get_local_election_pid(%{id: id, facility: facility} = _key) do
    case Registry.lookup(Ballot.Registry, {id, facility}) do
      [{pid, _}] -> {:ok, pid}
      _ -> nil
    end
  end
end
