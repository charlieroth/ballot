defmodule Ballot.Command.GetPoll do
  @enforce_keys [:poll_id]
  defstruct [:poll_id]
end
