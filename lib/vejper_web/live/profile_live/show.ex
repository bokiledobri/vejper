defmodule VejperWeb.ProfileLive.Show do
  use VejperWeb, :live_view
  alias Vejper.{Accounts, Social, Store}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      if socket.assigns.live_action == :edit,
        do: require_profile_completed(socket),
        else:
          socket
          |> assign(:current_page, :profiles)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Accounts.subscribe("chat", id)
    profile = Accounts.get_profile!(id)
    chat_ban = Accounts.banned?(id, "chat")
    store_ban = Accounts.banned?(id, "store")
    %{entries: posts, meta: social_meta} = Social.list_posts({NaiveDateTime.utc_now(), 5}, id)
    %{entries: ads, metadata: store_meta} = Store.list_ads(nil, %{}, id)

    items =
      Enum.concat(posts, ads)
      |> Enum.sort(fn %{updated_at: u}, %{updated_at: i} -> i < u end)

    socket =
      socket
      |> stream(:items, items,
        dom_id: fn item -> if is_post(item), do: "post-#{item.id}", else: "oglas-#{item.id}" end
      )
      |> assign(:social_meta, social_meta)
      |> assign(:store_meta, store_meta)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:chat_ban, chat_ban)
      |> assign(:store_ban, store_ban)
      |> assign(:profile, profile)

    {:noreply, socket}
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

  def handle_event("load-more", _params, socket) do
    %{entries: posts, meta: social_meta} =
      Social.list_posts(socket.assigns.social_meta, socket.assigns.profile.id)

    %{entries: ads, metadata: store_meta} =
      Store.list_ads(socket.assigns.store_meta.after, %{}, socket.assigns.profile.id)

    items =
      Enum.concat(posts, ads)
      |> Enum.sort(fn %{updated_at: u}, %{updated_at: i} -> i < u end)

    socket =
      Enum.reduce(items, socket, fn item, socket -> stream_insert(socket, :items, item) end)
      |> assign(:social_meta, social_meta)
      |> assign(:store_meta, store_meta)

    {:noreply, socket}
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

        chat_ban = Accounts.banned?(socket.assigns.profile.user.id, "chat")
        assign(socket, :chat_ban, chat_ban)
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

        store_ban = Accounts.banned?(socket.assigns.profile.user.id, "store")
        assign(socket, :store_ban, store_ban)
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

        ban = Accounts.banned?(socket.assigns.profile.user.id, "chat")
        socket = assign(socket, :chat_ban, ban)
        ban = Accounts.banned?(socket.assigns.profile.user.id, "store")
        socket = assign(socket, :store_ban, ban)
        socket
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:banned, _}, socket) do
    socket =
      socket
      |> assign(:chat_ban, Accounts.banned?(socket.assigns.profile.user.id, "chat"))
      |> assign(:store_ban, Accounts.banned?(socket.assigns.profile.user.id, "store"))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:unbanned, _}, socket) do
    socket =
      socket
      |> assign(:chat_ban, Accounts.banned?(socket.assigns.profile.user.id, "chat"))
      |> assign(:store_ban, Accounts.banned?(socket.assigns.profile.user.id, "store"))

    {:noreply, socket}
  end

  def is_post(%Social.Post{}) do
    true
  end

  def is_post(_) do
    false
  end

  defp page_title(:show), do: "Profil"
  defp page_title(:edit), do: "Uredi profil"
end
