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

  @spec parse_actor_server(actor_server :: String.t()) :: %{
          dc: String.t(),
          dc_az: String.t(),
          dc_node: String.t()
        }
  def parse_actor_server(actor_server) do
    [dc, dc_az, dc_node] = String.split(actor_server, "-")

    %{
      dc: dc,
      dc_az: dc_az,
      dc_node: dc_node
    }
  end

  @spec is_local_actor_server?(actor_server :: String.t()) :: boolean()
  def is_local_actor_server?(actor_server) do
    %{dc: actor_server_dc, dc_az: actor_server_dc_az, dc_node: actor_server_dc_node} =
      parse_actor_server(actor_server)

    %{dc: local_dc, dc_az: local_dc_az, dc_node: local_dc_node} = parse_node(Node.self())

    actor_server_dc == local_dc and actor_server_dc_az == local_dc_az and
      actor_server_dc_node == local_dc_node
  end

  @spec get_remote_node(actor_server :: String.t()) :: Node.t()
  def get_remote_node(actor_server) do
    %{dc: dc, dc_az: dc_az, dc_node: dc_node} =
      parse_actor_server(actor_server)

    :"#{dc}-#{dc_az}-#{dc_node}@localhost"
  end
end
