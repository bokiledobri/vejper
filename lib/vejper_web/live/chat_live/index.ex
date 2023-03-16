defmodule VejperWeb.ChatLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Chat
  alias Vejper.Chat.{Message, Room}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()
    rooms = Chat.list_rooms()

    socket =
      assign(socket, :current_user, Vejper.Repo.preload(socket.assigns.current_user, :chat_room))
      |> assign(:room, nil)
      |> stream(:rooms, rooms, dom_id: &"room-#{&1.id}")

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    if connected?(socket) do
      Chat.subscribe(id)
      Chat.subscribe()
    end

    room = Chat.get_room!(id)
    changeset = Chat.change_message(%Message{})
    %{entries: messages, meta: meta} = Chat.list_messages(id)

    socket =
      if socket.assigns.live_action == :show do
        stream(socket, :messages, messages, dom_id: &"message-#{&1.id}")
        |> assign(:room, room)
        |> assign(:meta, meta)
        |> assign_form(:message_form, changeset)
      else
        socket
      end

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
  def handle_event("delete-message", %{"message" => message_id}, socket) do
    message = Chat.get_message!(message_id)

    if message.user_id == socket.assigns.current_user.id do
      Chat.delete_message(message)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("load-more", _params, socket) do
    %{entries: messages, meta: meta} =
      Chat.list_messages(socket.assigns.room.id, socket.assigns.meta)

    socket =
      Enum.reduce(messages, socket, fn message, socket ->
        socket
        |> stream_insert(:messages, message)
        |> assign(:meta, meta)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:room_created, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  @impl true
  def handle_info({:room_updated, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  @impl true
  def handle_info({:message_sent, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message, at: 0)}
  end

  @impl true
  def handle_info({:message_deleted, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Uredi sobu")
    |> assign(:room, Chat.get_room!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova soba")
    |> assign(:room, %Room{})
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  defp assign_form(socket, form, %Ecto.Changeset{} = changeset) do
    assign(socket, form, to_form(changeset))
  end
end
