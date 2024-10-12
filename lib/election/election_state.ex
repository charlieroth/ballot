defmodule Election.State do
  @type t :: %Election.State{
          key: Election.Key.t()
        }

  defstruct [:key]

  def new(%Election.Key{} = election_key) do
    %Election.State{key: election_key}
  end
end
