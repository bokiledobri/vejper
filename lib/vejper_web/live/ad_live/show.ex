defmodule VejperWeb.AdLive.Show do
  use VejperWeb, :live_view

  alias Vejper.Store

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket, :uploaded_files, [])
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)

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
  def handle_params(%{"id" => id}, _, socket) do
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
