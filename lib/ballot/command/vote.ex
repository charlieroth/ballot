defmodule Ballot.Command.Vote do
  @enforce_keys [:voter_id, :poll_id, :option_id]
  defstruct [:voter_id, :poll_id, :option_id]
end
