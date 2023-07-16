defmodule BallotWeb.PollLive.Index do
  use BallotWeb, :live_view

  alias Ballot.Business
  alias Ballot.Business.Poll

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :polls, Business.list_polls())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:poll, Business.get_poll!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Polls")
    |> assign(:poll, nil)
  end

  @impl true
  def handle_info({BallotWeb.PollLive.FormComponent, {:saved, poll}}, socket) do
    {:noreply, stream_insert(socket, :polls, poll)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Business.get_poll!(id)
    {:ok, _} = Business.delete_poll(poll)

    {:noreply, stream_delete(socket, :polls, poll)}
  end
end
