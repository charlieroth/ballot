defmodule Election.Key do
  @type t :: %Election.Key{id: String.t(), facility: String.t()}

  defstruct [:id, :facility]

  def new(id, facility) do
    %Election.Key{id: id, facility: facility}
  end

  def to_name(%Election.Key{id: id, facility: facility}) do
    {id, facility}
  end
end
