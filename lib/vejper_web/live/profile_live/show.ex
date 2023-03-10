defmodule VejperWeb.ProfileLive.Show do
  use VejperWeb, :live_view
  alias Vejper.Accounts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [socket.assigns.current_user.profile.profile_image_url])
     |> allow_upload(:avatar, accept: ~w(.png .jpg .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:profile, Accounts.get_profile!(id))}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    user = socket.assigns.current_user

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:profile, user.profile)}
  end

  defp page_title(:show), do: "Prikaži profil"
  defp page_title(:edit), do: "Uredi profil"
end
