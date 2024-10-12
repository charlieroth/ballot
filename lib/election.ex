defmodule Election do
  use GenServer

  require Logger

  def start_link(%Election.Key{} = election_key) do
    GenServer.start_link(__MODULE__, election_key, name: via(election_key))
  end

  def process_command(%Election.Command.OpenElection{} = command) do
    GenServer.call(via(command.election_key), command)
  end

  def process_command(%Election.Command.CloseElection{} = command) do
    GenServer.call(via(command.election_key), command)
  end

  @impl true
  def init(%Election.Key{} = election_key) do
    state = Election.State.new(election_key)
    {:ok, state}
  end

  @impl true
  def handle_call(%Election.Command.OpenElection{} = command, _from, state) do
    Logger.info("[election:call] - OpenElection command received: #{inspect(command)}")
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(%Election.Command.CloseElection{} = command, _from, state) do
    Logger.info("[election:call] - CloseElection command received: #{inspect(command)}")
    {:reply, :ok, state}
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

  defp via(%Election.Key{} = election_key) do
    {:via}
    |> Tuple.append(Registry)
    |> Tuple.append({Ballot.Registry, Election.Key.to_name(election_key)})
  end
end
