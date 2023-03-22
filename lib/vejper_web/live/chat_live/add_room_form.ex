defmodule VejperWeb.ChatLive.AddRoomForm do
  use VejperWeb, :live_component

  alias Vejper.Chat

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <header>
        <%= @title %>
      </header>

      <.simple_form
        for={@form}
        id="room-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Naslov" />
        <:actions>
          <.button phx-disable-with="Čuvanje...">Sačuvaj</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{room: room} = assigns, socket) do
    changeset = Chat.change_room(room)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    save_room(socket.assigns.action, room_params, socket)
  end

  defp save_room(:new, params, socket) do
    case Chat.create_room(socket.assigns.current_user, params) do
      {:ok, _room} ->
        {:noreply, push_navigate(socket, to: ~p"/caskanje")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_room(:edit, params, socket) do
    if owner?(socket.assigns.room, socket) do
      case Chat.update_room(socket.assigns.room, params) do
        {:ok, _room} ->
          {:noreply, push_navigate(socket, to: ~p"/caskanje")}

        {:error, changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
