defmodule BallotTest do
  use ExUnit.Case
  doctest Ballot

  test "greets the world" do
    assert Ballot.hello() == :ballot
  end
end
