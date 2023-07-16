defmodule Ballot.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :value, :string
      add :poll_id, references(:polls, on_delete: :delete_all)

      timestamps()
    end

    create index(:options, [:poll_id])
  end
end
