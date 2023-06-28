defmodule Ballot.Mailroom do
  alias Ballot.Command

  alias Ballot.Command.{CreatePoll, Vote}

  @type command :: %CreatePoll{} | %Vote{}

  @spec dispatch(command()) :: :ok | {:error, term()}
  def dispatch(%CreatePoll{} = cmd), do: Command.handle(cmd)
  def dispatch(%Vote{} = cmd), do: Command.handle(cmd)
  def dispatch(_), do: {:error, :unknown_command}
end
