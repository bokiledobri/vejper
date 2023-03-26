defmodule VejperWeb.HomeLive.Index do
  use VejperWeb, :live_view
  alias Vejper.{Social, Store}

  def mount(_params, _session, socket) do
    %{entries: posts, meta: social_meta} = Social.list_posts()
    %{entries: ads, metadata: store_meta} = Store.list_ads(nil, %{})

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
      |> assign(:current_page, :home)

    {:ok, socket}
  end

  def handle_event("load-more", _params, socket) do
    %{entries: posts, meta: social_meta} = Social.list_posts(socket.assigns.social_meta)
    %{entries: ads, metadata: store_meta} = Store.list_ads(socket.assigns.store_meta.after, %{})

    items =
      Enum.concat(posts, ads)
      |> Enum.sort(fn %{updated_at: u}, %{updated_at: i} -> i < u end)

    IO.inspect(socket.assigns.store_meta.after)

    socket =
      Enum.reduce(items, socket, fn item, socket -> stream_insert(socket, :items, item) end)
      |> assign(:social_meta, social_meta)
      |> assign(:store_meta, store_meta)

    {:noreply, socket}
  end

  def is_post(%Social.Post{}) do
    true
  end

  def is_post(_) do
    false
  end
end
