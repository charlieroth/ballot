defmodule Ballot do
  @moduledoc false
  alias Ballot.Router
  alias Ballot.Command.CreateParticipant

  @doc """
  Creates a participant in the Ballot network
  """
  @spec create_participant(String.t()) :: :ok | {:error, term()}
  def create_participant(identifier) do
    %CreateParticipant{identifier: identifier}
    |> Router.dispatch()
  end
end
