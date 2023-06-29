defmodule Ballot.PollSupervisor do
  use DynamicSupervisor
  alias Ballot.Command.Create
  alias Ballot.Poll

  def create(%Create{} = create_event) do
    DynamicSupervisor.start_child(__MODULE__, {Poll, create_event})
  end

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
