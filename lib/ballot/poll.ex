defmodule Ballot.Poll do
  use GenServer, restart: :transient

  def start_link(%{id: id, zone: _zone} = key) do
    GenServer.start_link(__MODULE__, key, name: via_tuple(id))
  end

  def child_spec(key) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [key]}}
  end

  defp via_tuple(id) do
    {:via, Registry, {Ballot.Poll, id}}
  end

  @impl true
  def init(key) do
    {:ok,
     %{
       key: key,
       projections: %{},
       event_store: []
     }}
  end
end
