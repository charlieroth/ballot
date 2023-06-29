defmodule Ballot.Mailroom do
  alias Ballot.Command

  alias Ballot.Command.{Create, Vote}

  @type command :: %Create{} | %Vote{}

  @spec dispatch(command()) :: :ok | {:error, term()}
  def dispatch(%Create{} = cmd), do: Command.handle(cmd)
  def dispatch(%Vote{} = cmd), do: Command.handle(cmd)
  def dispatch(_), do: {:error, :unknown_command}
end
