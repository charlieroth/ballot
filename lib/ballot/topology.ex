defmodule Ballot.Topology do
  @doc """
  The Topology module is the solution to the problem of
  a globally consistent process registry. Globally consistent
  process registries are very expensive so we use a topology
  built on top of libring to provide a consistent process registry
  using a consistent hashing algorithm. Therefore we have consensus
  via topology and not via a global process registry.

  The topology is a map of datacenters to hash rings. Each hash ring is a
  libring HashRing.t() struct. The keys of the hash ring are the IDs of the
  nodes in the datacenter
  """
  @spec get_current() :: %{required(String.t()) => HashRing.t()}
  def get_current() do
    %{}
  end

  @spec get_dcs() :: [String.t()]
  def get_dcs() do
    []
  end

  @spec get_dc_hash_ring(String.t()) :: HashRing.t() | {:error, String.t()}
  def get_dc_hash_ring(_dc) do
    {:error, "Not implemented"}
  end

  @spec get_actor_server(%{required(:id) => String.t(), required(:zone) => String.t()}) ::
          String.t() | {:error, String.t()}
  def get_actor_server(%{id: _actor_id, zone: _zone}) do
    {:error, "Not implemented"}
  end
end
