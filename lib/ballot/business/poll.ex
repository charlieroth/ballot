defmodule Ballot.Business.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ballot.Business.Option

  schema "polls" do
    field :status, :string
    field :question, :string
    has_many :options, Option

    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:question, :status])
    |> validate_required([:question, :status])
  end
end
