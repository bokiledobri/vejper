defmodule VejperWeb.Admin.CategoryAssociateFieldsComponent do
  use VejperWeb, :live_component

  alias Vejper.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-5 rounded gap-2 ">
      <ul
        id="dropzone-left"
        phx-hook="Dropzone"
        phx-target={@myself}
        class="overflow-auto pb-2 bg-zinc-200 dark:bg-zinc-800 col-span-2 h-[100vh]"
      >
        <h3 class="font-bold text-xl border-b-2 border-solid bg-zinc-100 dark:bg-zinc-900 border-black dark:border-white pt-2 pb-4 text-center">
          <%= @category.name %>
        </h3>
        <li
          :for={field <- @category.fields}
          id={"left-#{field.id}"}
          phx-hook="Dropped"
          draggable="true"
          class="border-solid mx-2 border-b-2 p-3 border-zinc-800 cursor-grab active:cursor-grabbing dark:border-zinc-200"
        >
          <div class="font-bold">
            <%= field.name %>
          </div>
          <div class="italic text-xs">
            <%= field.type %>
          </div>
        </li>
      </ul>
      <ul
        class="overfflow-auto pb-2 bg-zinc-300 dark:bg-zinc-700 col-span-3 h-[100vh] rounded-r"
        id="dropzone-right"
        phx-hook="Dropzone"
      >
        <h3 class="font-bold text-xl border-b-2 border-solid bg-zinc-200 dark:bg-zinc-800 border-black dark:border-white pt-2 pb-4 text-center">
          Ostala polja
        </h3>
        <li
          :for={field <- @fields}
          id={"right-#{field.id}"}
          phx-hook="Dropped"
          draggable="true"
          class="border-solid border-b-2 mx-2 p-3 cursor-grab active:cursor-grabbing border-zinc-800 dark:border-zinc-200"
        >
          <div class="font-bold">
            <%= field.name %>
          </div>
          <div class="italic text-xs">
            <%= field.type %>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    fields =
      Store.list_fields()
      |> Enum.filter(fn fi ->
        Enum.any?(category.fields, fn r -> r.id == fi.id end) == false
      end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:fields, fields)}
  end
end
