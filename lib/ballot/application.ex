defmodule Ballot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = get_children(Mix.env())

    opts = [strategy: :one_for_one, name: Ballot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_children(:prod) do
    topologies = Application.get_env(:libcluster, :topologies)

    [
      {Registry, keys: :unique, name: Ballot.Registry},
      {Cluster.Supervisor, [topologies, [name: Ballot.ClusterSupervisor]]},
      Topology,
      Mailroom,
      Election.Supervisor
    ]
  end

  def get_children(:dev) do
    topologies = Application.get_env(:libcluster, :topologies)

    [
      {Registry, keys: :unique, name: Ballot.Registry},
      {Cluster.Supervisor, [topologies, [name: Ballot.ClusterSupervisor]]},
      Topology,
      Mailroom,
      Election.Supervisor
    ]
  end

  def get_children(:test) do
    [
      {Registry, keys: :unique, name: Ballot.Registry}
    ]
  end
end
