defmodule Ballot do
  @moduledoc false
  alias Ballot.PollSupervisor
  alias Ecto.UUID
  alias Ballot.Mailroom

  alias Ballot.Command.{Create, Vote}

  @doc """
  Creates a Poll in the Ballot network
  """
  @spec create_poll(String.t(), String.t(), [String.t()]) :: {:ok, String.t()} | {:error, term()}
  def create_poll(question, type, options) do
    %Create{id: UUID.generate(), question: question, type: type, options: options}
    |> PollSupervisor.create()
  end

  # @doc """
  # Votes in a Poll in the Ballot network
  # """
  # @spec vote(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  # def vote(poll_id, option_id, voter_id) do
  #   %Vote{poll_id: poll_id, option_id: option_id, voter_id: voter_id}
  #   |> Mailroom.dispatch()
  # end
end
