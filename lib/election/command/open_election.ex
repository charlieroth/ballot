defmodule Election.Command.OpenElection do
  @moduledoc """
  Command to open an election.
  """

  @type t :: %__MODULE__{
          election_key: Election.Key.t()
        }

  defstruct [:election_key]

  @spec new(election_key :: Election.Key.t()) :: t()
  def new(election_key) do
    %__MODULE__{
      election_key: election_key
    }
  end
end
