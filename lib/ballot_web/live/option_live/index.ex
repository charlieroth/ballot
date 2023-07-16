defmodule BallotWeb.OptionLive.Index do
  use BallotWeb, :live_view

  alias Ballot.Business
  alias Ballot.Business.Option

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :options, Business.list_options())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Option")
    |> assign(:option, Business.get_option!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Option")
    |> assign(:option, %Option{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Options")
    |> assign(:option, nil)
  end

  @impl true
  def handle_info({BallotWeb.OptionLive.FormComponent, {:saved, option}}, socket) do
    {:noreply, stream_insert(socket, :options, option)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    option = Business.get_option!(id)
    {:ok, _} = Business.delete_option(option)

    {:noreply, stream_delete(socket, :options, option)}
  end
end
