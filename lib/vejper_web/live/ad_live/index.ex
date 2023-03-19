defmodule VejperWeb.AdLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Store.Query
  alias Vejper.Store
  alias Vejper.Store.Ad

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Store.subscribe()
    {prices, categories, cities, states} = Store.get_query_metadata()

    query_params = %{"min_price" => prices.min, "max_price" => prices.max}

    query = Store.change_query(%Query{}, query_params)
    %{entries: ads, metadata: meta} = Store.list_ads(nil, %{})

    socket =
      assign(socket, :uploaded_files, [])
      |> assign(:after, meta.after)
      |> assign(:images, nil)
      |> assign(:prices, prices)
      |> assign(:cities, cities)
      |> assign(:states, states)
      |> assign(:query_params, query_params)
      |> assign(:query_categories, categories)
      |> assign_form(query)
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)

    {:ok, stream(socket, :ads, ads, dom_id: &"oglas-#{&1.id}")}
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
  def handle_info({:ad_updated, ad}, socket) do
    {:noreply, stream_insert(socket, :ads, ad)}
  end

  @impl true
  def handle_info({:ad_deleted, ad}, socket) do
    {:noreply, stream_delete(socket, :ads, ad)}
  end

  @impl true
  def handle_event("load-more", _params, socket) do
    %{entries: ads, metadata: meta} =
      Store.list_ads(socket.assigns.after, socket.assigns.query_params)

    socket =
      Enum.reduce(ads, socket, fn ad, socket ->
        socket
        |> stream_insert(:ads, ad)
        |> assign(:after, meta.after)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ad = Store.get_ad!(id)

    if check_owner(ad, socket) do
      Store.delete_ad(ad)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("range-changed", %{"query" => %{"max_price" => price}}, socket) do
    params = Map.put(socket.assigns.query_params, "max_price", price)
    query = Store.change_query(%Query{}, params)
    {:noreply, assign_form(socket, query)}
  end

  @impl true
  def handle_event("range-changed", %{"query" => %{"min_price" => price}}, socket) do
    params = Map.put(socket.assigns.query_params, "min_price", price)
    query = Store.change_query(%Query{}, params)
    {:noreply, assign_form(socket, query)}
  end

  @impl true
  def handle_event("query-ads", %{"query" => params}, socket) do
    query = Store.change_query(%Query{}, params)
    %{entries: ads, metadata: meta} = Store.list_ads(nil, params)
    socket = Enum.reduce(ads, socket, fn ad, s -> stream_insert(s, :ads, ad) end)

    socket =
      socket
      |> assign_form(query)
      |> assign(:after, meta.after)
      |> assign(:query_params, params)

    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset)
    assign(socket, :query_form, form)
  end
end
