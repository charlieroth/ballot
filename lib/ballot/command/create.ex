defmodule Ballot.Command.Create do
  @enforce_keys [:id, :question, :type, :options]
  defstruct [:id, :question, :type, :options]
end
