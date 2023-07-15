defmodule Ballot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BallotWeb.Telemetry,
      Ballot.Repo,
      {Phoenix.PubSub, name: Ballot.PubSub},
      {Finch, name: Ballot.Finch},
      BallotWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Ballot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BallotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
