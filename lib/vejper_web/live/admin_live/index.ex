defmodule VejperWeb.AdminLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Store
  alias Vejper.Store.Category
  alias VejperWeb.Presence
  alias Vejper.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Vejper.PubSub, "admin")
    {online, without_profile} = get_online_users()
    online = Enum.uniq(online)

    socket =
      stream(socket, :categories, Store.list_categories())
      |> assign(:online_users, online)
      |> assign(:online_without_profile, without_profile)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Uredi kategoriju")
    |> assign(:category, Store.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Dodaj kategoriju")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Admin")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({VejperWeb.Admin.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_info(:online_users_updated, socket) do
    {online, without_profile} = get_online_users()
    online = Enum.uniq(online)

    socket =
      socket
      |> assign(:online_users, online)
      |> assign(:online_without_profile, without_profile)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Store.get_category!(id)
    {:ok, _} = Store.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end

  defp get_online_users() do
    {_, %{metas: users}} =
      Presence.list("users")
      |> Enum.at(0)

    Enum.reduce(users, {[], 0}, fn u, {a, n} ->
      if u.id do
        {Enum.concat(a, [Accounts.get_profile!(u.id)]), n}
      else
        {a, n + 1}
      end
    end)
  end
end
