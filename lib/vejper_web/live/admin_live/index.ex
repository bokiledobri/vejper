defmodule VejperWeb.AdminLive.Index do
  use VejperWeb, :live_view

  def mount(_params, _session, socket) do
    categories = Store.list_categories()
    fields = Store.list_fields()

    socket =
      assign(socket(:categories, categories))
      |> assign(:fields, fields)

    {:ok, socket}
  end
end
