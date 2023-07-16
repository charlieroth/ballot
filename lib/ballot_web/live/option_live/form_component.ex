defmodule BallotWeb.OptionLive.FormComponent do
  use BallotWeb, :live_component

  alias Ballot.Business

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage option records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="option-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:value]} type="text" label="Value" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Option</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{option: option} = assigns, socket) do
    changeset = Business.change_option(option)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"option" => option_params}, socket) do
    changeset =
      socket.assigns.option
      |> Business.change_option(option_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"option" => option_params}, socket) do
    save_option(socket, socket.assigns.action, option_params)
  end

  defp save_option(socket, :edit, option_params) do
    case Business.update_option(socket.assigns.option, option_params) do
      {:ok, option} ->
        notify_parent({:saved, option})

        {:noreply,
         socket
         |> put_flash(:info, "Option updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_option(socket, :new, option_params) do
    case Business.create_option(option_params) do
      {:ok, option} ->
        notify_parent({:saved, option})

        {:noreply,
         socket
         |> put_flash(:info, "Option created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
