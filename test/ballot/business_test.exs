defmodule Ballot.BusinessTest do
  use Ballot.DataCase

  alias Ballot.Business

  describe "polls" do
    alias Ballot.Business.Poll

    import Ballot.BusinessFixtures

    @invalid_attrs %{status: nil, question: nil}

    test "list_polls/0 returns all polls" do
      poll = poll_fixture()
      assert Business.list_polls() == [poll]
    end

    test "get_poll!/1 returns the poll with given id" do
      poll = poll_fixture()
      assert Business.get_poll!(poll.id) == poll
    end

    test "create_poll/1 with valid data creates a poll" do
      valid_attrs = %{status: "some status", question: "some question"}

      assert {:ok, %Poll{} = poll} = Business.create_poll(valid_attrs)
      assert poll.status == "some status"
      assert poll.question == "some question"
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_poll(@invalid_attrs)
    end

    test "update_poll/2 with valid data updates the poll" do
      poll = poll_fixture()
      update_attrs = %{status: "some updated status", question: "some updated question"}

      assert {:ok, %Poll{} = poll} = Business.update_poll(poll, update_attrs)
      assert poll.status == "some updated status"
      assert poll.question == "some updated question"
    end

    test "update_poll/2 with invalid data returns error changeset" do
      poll = poll_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_poll(poll, @invalid_attrs)
      assert poll == Business.get_poll!(poll.id)
    end

    test "delete_poll/1 deletes the poll" do
      poll = poll_fixture()
      assert {:ok, %Poll{}} = Business.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Business.get_poll!(poll.id) end
    end

    test "change_poll/1 returns a poll changeset" do
      poll = poll_fixture()
      assert %Ecto.Changeset{} = Business.change_poll(poll)
    end
  end

  describe "options" do
    alias Ballot.Business.Option

    import Ballot.BusinessFixtures

    @invalid_attrs %{value: nil}

    test "list_options/0 returns all options" do
      option = option_fixture()
      assert Business.list_options() == [option]
    end

    test "get_option!/1 returns the option with given id" do
      option = option_fixture()
      assert Business.get_option!(option.id) == option
    end

    test "create_option/1 with valid data creates a option" do
      valid_attrs = %{value: "some value"}

      assert {:ok, %Option{} = option} = Business.create_option(valid_attrs)
      assert option.value == "some value"
    end

    test "create_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_option(@invalid_attrs)
    end

    test "update_option/2 with valid data updates the option" do
      option = option_fixture()
      update_attrs = %{value: "some updated value"}

      assert {:ok, %Option{} = option} = Business.update_option(option, update_attrs)
      assert option.value == "some updated value"
    end

    test "update_option/2 with invalid data returns error changeset" do
      option = option_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_option(option, @invalid_attrs)
      assert option == Business.get_option!(option.id)
    end

    test "delete_option/1 deletes the option" do
      option = option_fixture()
      assert {:ok, %Option{}} = Business.delete_option(option)
      assert_raise Ecto.NoResultsError, fn -> Business.get_option!(option.id) end
    end

    test "change_option/1 returns a option changeset" do
      option = option_fixture()
      assert %Ecto.Changeset{} = Business.change_option(option)
    end
  end
end
