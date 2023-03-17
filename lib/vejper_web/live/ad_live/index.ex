defmodule VejperWeb.AdLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Store
  alias Vejper.Store.Ad

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Store.subscribe()

    socket =
      assign(socket, :uploaded_files, [])
      |> assign(:images, nil)
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)

    {:ok, stream(socket, :ads, Store.list_store_ads(), dom_id: &"oglas-#{&1.id}")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novi oglas")
    |> assign(:ad, %Ad{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Oglasi")
    |> assign(:ad, nil)
  end

  @impl true
  def handle_info({:ad_created, ad}, socket) do
    {:noreply, stream_insert(socket, :ads, ad)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ad = Store.get_ad!(id)
    {:ok, _} = Store.delete_ad(ad)

    {:noreply, stream_delete(socket, :store_ads, ad)}
  end
end
