defmodule BallotWeb.OptionLive.Show do
  use BallotWeb, :live_view

  alias Ballot.Business

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:option, Business.get_option!(id))}
  end

  defp page_title(:show), do: "Show Option"
  defp page_title(:edit), do: "Edit Option"
end
