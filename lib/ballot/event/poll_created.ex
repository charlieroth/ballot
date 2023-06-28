defmodule Ballot.Event.PollCreated do
  defstruct [:poll_id, :question, :options]
end
