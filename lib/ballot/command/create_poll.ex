defmodule Ballot.Command.CreatePoll do
  @enforce_keys [:question, :type, :options]
  defstruct [:question, :type, :options]
end
