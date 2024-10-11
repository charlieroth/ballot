defmodule Election.Command.OpenElection do
  @moduledoc """
  Command to open an election.
  """

  @type t :: %__MODULE__{
          election_id: String.t(),
          facility: String.t()
        }

  defstruct [:election_id, :facility]

  @spec new(String.t(), String.t()) :: t()
  def new(election_id, facility) do
    %__MODULE__{
      election_id: election_id,
      facility: facility
    }
  end
end
