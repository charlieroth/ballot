defmodule Ballot.BusinessFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ballot.Business` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        status: "some status",
        question: "some question"
      })
      |> Ballot.Business.create_poll()

    poll
  end

  @doc """
  Generate a option.
  """
  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        value: "some value"
      })
      |> Ballot.Business.create_option()

    option
  end
end
