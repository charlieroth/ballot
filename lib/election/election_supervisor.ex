defmodule Election.Supervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(key) do
    child_spec = {Election, key}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
