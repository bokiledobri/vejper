defmodule VejperWeb.ChatLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Chat
  alias Vejper.Chat.Message

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()
    rooms = Chat.list_rooms()

    {:ok, stream(socket, :rooms, rooms, dom_id: &"room-#{&1.id}")}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    if connected?(socket), do: Chat.subscribe(id)
    room = Chat.get_room!(id)
    changeset = Chat.change_message(%Message{})
    messages = Chat.list_messages(id)

    socket =
      stream(socket, :messages, messages, dom_id: &"message-#{&1.id}")
      |> assign(:room, room)
      |> assign_form(:message_form, changeset)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"message" => _message_params}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"message" => message_params}, socket) do
    case Chat.create_message(socket.assigns.room, socket.assigns.current_user, message_params) do
      {:ok, _comment} ->
        socket =
          socket
          |> push_event("clear-input", %{id: "send-message-input"})

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, :message_form, changeset)}
    end
  end

  @impl true
  def handle_info({:message_sent, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message, at: 0)}
  end

  def apply_action(socket, _action, _params) do
    socket
  end

  defp assign_form(socket, form, %Ecto.Changeset{} = changeset) do
    assign(socket, form, to_form(changeset))
  end
end
