defmodule VejperWeb.AdLive.Show do
  use VejperWeb, :live_view

  alias Vejper.Store

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("image-prev", _params, socket) do
    index =
      if socket.assigns.active_image_index == 0 do
        Enum.count(socket.assigns.ad.images) - 1
      else
        socket.assigns.active_image_index - 1
      end

    socket =
      assign(socket, :active_image_index, index)
      |> assign(:active_image, Enum.at(socket.assigns.ad.images, index))

    {:noreply, socket}
  end

  @impl true
  def handle_event("image-next", _params, socket) do
    index =
      if socket.assigns.active_image_index == Enum.count(socket.assigns.ad.images) - 1 do
        0
      else
        socket.assigns.active_image_index + 1
      end

    socket =
      assign(socket, :active_image_index, index)
      |> assign(:active_image, Enum.at(socket.assigns.ad.images, index))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:ad_updated, ad}, socket) do
    {:noreply, assign(socket, :ad, ad)}
  end

  @impl true
  def handle_info({:ad_deleted, _ad}, socket) do
    socket =
      put_flash(socket, :info, "Oglas koji ste gledali upravo je obrisan")
      |> push_navigate(to: ~p"/store_ads")

    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if connected?(socket), do: Store.subscribe(id)
    ad = Store.get_ad!(id)

    {:noreply,
     socket
     |> assign(:page_title, ad.title)
     |> assign(:ad, ad)
     |> assign(:images, ad.images)
     |> assign(:active_image, Enum.at(ad.images, 0))
     |> assign(:active_image_index, 0)}
  end
end
