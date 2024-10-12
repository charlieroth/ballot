defmodule Election do
  use GenServer

  require Logger

  @type key :: %{id: String.t(), facility: String.t()}

  def start_link(key) do
    GenServer.start_link(__MODULE__, key, name: via(key))
  end

  def get_state(key) do
    GenServer.call(via(key), :get_state)
  end

  def process_msg(%Message{key: key} = msg) do
    GenServer.call(via(key), msg)
  end

  @impl true
  def init(key) do
    state = Election.State.new(key)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(%Message{} = msg, _from, state) do
    Logger.info("[election:call] - msg received: #{inspect(msg)}")
    new_state = Election.State.process_command(state, msg)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.info("[election:call] - unknown call: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.info("[election:cast] - unknown cast: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("[election:info] - unknown info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("[election:terminate] - terminating: #{inspect(reason)}")
    :ok
  end

  defp via(key) do
    {:via}
    |> Tuple.append(Registry)
    |> Tuple.append({Ballot.Registry, key})
  end
end
