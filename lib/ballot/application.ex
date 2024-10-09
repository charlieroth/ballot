defmodule Ballot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Registry, keys: :unique, name: Ballot.Registry},
      {Cluster.Supervisor, [topologies, [name: Ballot.ClusterSupervisor]]},
      Topology
    ]

    opts = [strategy: :one_for_one, name: Ballot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
