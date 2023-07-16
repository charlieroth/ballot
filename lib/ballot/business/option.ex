defmodule Ballot.Business.Option do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ballot.Business.Poll

  schema "options" do
    field :value, :string
    belongs_to :poll, Poll

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:value])
    |> validate_required([:value])
  end
end
