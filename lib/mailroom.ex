defmodule Mailroom do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def dispatch(command) do
    GenServer.cast(__MODULE__, {:dispatch, command})
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.info("[mailroom:call] - unknown call message received: #{inspect(msg)}")
    {:reply, nil, state}
  end

  @impl true
  def handle_cast({:dispatch, command}, state) do
    Logger.info("[mailroom:cast] - received command: #{inspect(command)}")
    # actor_server = Topology.get_actor_server(command.key)

    # TODO: Implement command dispatch protocol
    # 1) If the intended receipient is a local `Election` process, 
    #  1a) If the local `Election` process is already running,
    #    1a1) Send command to local `Election` process
    #  1b) If the local `Election` process is not running,
    #    1b1) Start local `Election` process
    #    1b2) Send command to local `Election` process
    # 2) If the intended receipient is a remote `Election` process,
    #  2a) Get the intended receipient's node
    #  2b) Send command to remote `Mailroom` process
    {:noreply, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.info("[mailroom:cast] - unknown cast message received: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("[mailroom:info] - unknown info message received: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("[mailroom:terminate] - terminating: #{inspect(reason)}")
    :ok
  end
end
