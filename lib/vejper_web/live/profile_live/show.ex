defmodule VejperWeb.ProfileLive.Show do
  use VejperWeb, :live_view
  alias Vejper.Accounts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    profile = Accounts.get_profile!(id)
    chat_bans = Accounts.list_bans_by_user_and_type(id, "chat")
    store_bans = Accounts.list_bans_by_user_and_type(id, "store")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:chat_bans, chat_bans)
     |> assign(:store_bans, store_bans)
     |> assign(:profile, profile)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    user = socket.assigns.current_user

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:profile, user.profile |> Vejper.Repo.preload(:user))}
  end

  @impl true
  def handle_event("assign-mod", %{"mod" => mod}, socket) do
    if admin?(socket) do
      Accounts.assign_mod(socket.assigns.profile.user, mod)
    end

    user = Accounts.get_user!(socket.assigns.profile.user.id)
    {:noreply, assign(socket, :profile, Map.put(socket.assigns.profile, :user, user))}
  end

  @impl true
  def handle_event("deassign-mod", %{"mod" => mod}, socket) do
    if admin?(socket) do
      Accounts.deassign_mod(socket.assigns.profile.user, mod)
    end

    user = Accounts.get_user!(socket.assigns.profile.user.id)
    {:noreply, assign(socket, :profile, Map.put(socket.assigns.profile, :user, user))}
  end

  @impl true
  def handle_event("ban-from-chat", %{"hours" => hours}, socket) do
    socket =
      if chat_mod?(socket) do
        Accounts.ban_user(
          "chat",
          String.to_integer(hours),
          socket.assigns.profile.user,
          socket.assigns.current_user
        )

        chat_bans = Accounts.list_bans_by_user_and_type(socket.assigns.profile.id, "chat")
        assign(socket, :chat_bans, chat_bans)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("ban-from-store", %{"hours" => hours}, socket) do
    socket =
      if chat_mod?(socket) do
        Accounts.ban_user(
          "store",
          String.to_integer(hours),
          socket.assigns.profile.user,
          socket.assigns.current_user
        )

        store_bans = Accounts.list_bans_by_user_and_type(socket.assigns.profile.id, "store")
        assign(socket, :store_bans, store_bans)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-ban", %{"id" => id}, socket) do
    socket =
      if chat_mod?(socket) do
        Accounts.get_ban!(id)
        |> Accounts.unban_user()

        chat_bans = Accounts.list_bans_by_user_and_type(socket.assigns.profile.id, "chat")
        assign(socket, :chat_bans, chat_bans)
      else
        socket
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Prikaži profil"
  defp page_title(:edit), do: "Uredi profil"
end
