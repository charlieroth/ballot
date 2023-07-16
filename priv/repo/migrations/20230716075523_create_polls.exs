defmodule Ballot.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :question, :string
      add :status, :string

      timestamps()
    end
  end
end
