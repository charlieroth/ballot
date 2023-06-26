defmodule Ballot.Repo do
  use Ecto.Repo,
    otp_app: :ballot,
    adapter: Ecto.Adapters.Postgres
end
