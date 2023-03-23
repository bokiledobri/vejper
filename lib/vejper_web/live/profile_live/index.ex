defmodule VejperWeb.ProfileLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Accounts
  alias Vejper.Accounts.Profile

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:profiles, Accounts.list_profiles())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    user = socket.assigns.current_user

    profile = user.profile

    socket
    |> assign(:page_title, "Uredi profil")
    |> assign(:profile, profile)
    |> assign(:uploaded_files, [profile.image.url])
    |> allow_upload(:avatar, accept: ~w(.png .jpg .jpeg), max_entries: 1)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Napravi profil")
    |> assign(:profile, %Profile{})
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar, accept: ~w(.png .jpg .jpeg), max_entries: 1)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Profili")
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info({VejperWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Accounts.get_profile!(id)
    {:ok, _} = Accounts.delete_profile(profile)

    {:noreply, stream_delete(socket, :profiles, profile)}
  end
end
