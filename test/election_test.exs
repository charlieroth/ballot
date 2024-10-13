defmodule TestElection do
  use ExUnit.Case

  setup do
    key = %{id: "1001", facility: "VC-123"}
    {:ok, _pid} = Election.start_link(key)
    %{key: key}
  end

  test "open and close an election", %{key: key} do
    open_election_cmd = %Message{key: key, kind: :open_election, payload: %{}}
    :ok = Election.process_command(open_election_cmd)

    state = Election.get_state(key)

    assert state.event_store == [
             %Message{key: key, kind: :election_opened, payload: %{}}
           ]

    assert state.projections == %{
             status: :open,
             casted_ballots: 0,
             validated_ballots: 0,
             invalidated_ballots: 0
           }

    close_election_cmd = %Message{key: key, kind: :close_election, payload: %{}}
    :ok = Election.process_command(close_election_cmd)

    state = Election.get_state(key)

    assert state.event_store == [
             %Message{key: key, kind: :election_closed, payload: %{}},
             %Message{key: key, kind: :election_opened, payload: %{}}
           ]

    assert state.projections == %{
             status: :closed,
             casted_ballots: 0,
             validated_ballots: 0,
             invalidated_ballots: 0
           }
  end

  test "open an election, cast ballots, close the election", %{key: key} do
    open_election_cmd = %Message{key: key, kind: :open_election, payload: %{}}
    :ok = Election.process_command(open_election_cmd)

    state = Election.get_state(key)

    assert state.event_store == [
             %Message{key: key, kind: :election_opened, payload: %{}}
           ]

    assert state.projections == %{
             status: :open,
             casted_ballots: 0,
             validated_ballots: 0,
             invalidated_ballots: 0
           }

    cast_ballot_cmd = %Message{key: key, kind: :cast_ballot, payload: %{}}
    :ok = Election.process_command(cast_ballot_cmd)

    state = Election.get_state(key)

    assert state.event_store == [
             %Message{key: key, kind: :ballot_casted, payload: %{}},
             %Message{key: key, kind: :election_opened, payload: %{}}
           ]

    assert state.projections == %{
             status: :open,
             casted_ballots: 1,
             validated_ballots: 0,
             invalidated_ballots: 0
           }

    close_election_cmd = %Message{key: key, kind: :close_election, payload: %{}}
    :ok = Election.process_command(close_election_cmd)

    state = Election.get_state(key)

    assert state.event_store == [
             %Message{key: key, kind: :election_closed, payload: %{}},
             %Message{key: key, kind: :ballot_casted, payload: %{}},
             %Message{key: key, kind: :election_opened, payload: %{}}
           ]

    assert state.projections == %{
             status: :closed,
             casted_ballots: 1,
             validated_ballots: 0,
             invalidated_ballots: 0
           }
  end
end
