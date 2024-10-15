defmodule TestElection do
  use ExUnit.Case

  setup do
    key = %{id: "1001", facility: "VC-123"}
    {:ok, _pid} = Election.start_link(key)
    %{key: key}
  end

  describe "election open, close, validate, invalidate lifecycle" do
    test "fails to open election that is not idle", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :open_election, payload: %{}}
             ]) == {:error, :failed_to_open_election}
    end

    test "fails to open election that is already open", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :open_election, payload: %{}}
             ]) == {:error, :failed_to_open_election}
    end

    test "fails to re-open election if marked as valid", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}},
               %Message{key: key, kind: :validate_election, payload: %{}},
               %Message{key: key, kind: :open_election, payload: %{}}
             ]) == {:error, :failed_to_open_election}
    end

    test "fails to close election that is not open", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :close_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}}
             ]) == {:error, :failed_to_close_election}
    end

    test "fails to close election that is already closed", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}}
             ]) == {:error, :failed_to_close_election}
    end

    test "fails to close election that valid", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}},
               %Message{key: key, kind: :validate_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}}
             ]) == {:error, :failed_to_close_election}
    end

    test "fails to invalidate an election that is already invalidated", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :invalidate_election, payload: %{}},
               %Message{key: key, kind: :invalidate_election, payload: %{}}
             ]) == {:error, :failed_to_invalidate_election}
    end

    test "fails to invalidate an non-closed election", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :invalidate_election, payload: %{}}
             ]) == {:error, :failed_to_invalidate_election}
    end

    test "successfully re-opens an invalidated election", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}},
               %Message{key: key, kind: :invalidate_election, payload: %{}},
               %Message{key: key, kind: :open_election, payload: %{}}
             ]) == :ok
    end
  end

  describe "ballot casting lifecycle" do
    test "fails to cast ballot for a closed election", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :open_election, payload: %{}},
               %Message{key: key, kind: :close_election, payload: %{}},
               %Message{key: key, kind: :cast_ballot, payload: %{voter_signature: "sig_123"}}
             ]) == {:error, :failed_to_cast_ballot}
    end

    test "fails to cast ballot for an idle election", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :cast_ballot, payload: %{voter_signature: "sig_123"}}
             ]) == {:error, :failed_to_cast_ballot}
    end

    test "fails to cast ballot with same voter signature twice", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :cast_ballot, payload: %{voter_signature: "sig_123"}},
               %Message{key: key, kind: :cast_ballot, payload: %{voter_signature: "sig_123"}}
             ]) == {:error, :failed_to_cast_ballot}
    end

    test "fails to validate ballot when no casted ballot with same voter signature", %{key: key} do
      assert process_commands([
               %Message{key: key, kind: :validate_ballot, payload: %{voter_signature: "sig_123"}}
             ]) == {:error, :failed_to_validate_ballot}
    end

    test "fails to invalidate ballot when no casted ballot with same voter signature", %{key: key} do
      assert process_commands([
               %Message{
                 key: key,
                 kind: :invalidate_ballot,
                 payload: %{voter_signature: "sig_123"}
               }
             ]) == {:error, :failed_to_invalidate_ballot}
    end
  end

  defp process_commands(commands) do
    Enum.reduce(commands, :ok, fn command, _acc ->
      Election.process_command(command)
    end)
  end
end
