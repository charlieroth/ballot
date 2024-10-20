defmodule Ballot.ClusterNode do
  @moduledoc false
  @type t :: %__MODULE__{
          name: String.t(),
          host: String.t(),
          dc: String.t(),
          dc_az: String.t(),
          dc_node: String.t()
        }
  @enforce_keys [:name, :host, :dc, :dc_az, :dc_node]
  defstruct [:name, :host, :dc, :dc_az, :dc_node]

  def get_dc_az(%Ballot.ClusterNode{dc: dc, dc_az: dc_az} = _cluster_node) do
    "#{dc}-#{dc_az}"
  end
end
