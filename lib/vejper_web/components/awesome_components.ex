defmodule VejperWeb.AwesomeComponents do
  use Phoenix.Component
  import VejperWeb.CoreComponents
  attr :show, :any
  attr :form, :any, required: true
  attr :form_id, :string, required: true
  attr :class, :string, default: "w-full flex items-start"
  attr :placeholder, :string, default: ""
  attr :input_id, :string, required: true

  def awesome_input(assigns) do
    ~H"""
    <%= if @show do %>
      <.form for={@form} id={@form_id} phx-change="validate" phx-submit="save" class={@class}>
        <div class="relative w-full">
          <.input
            id={@input_id}
            placeholder={@placeholder}
            class="py-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2.5  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            field={@form[:body]}
            type="text"
          />
        </div>
        <.button phx-disable-with="Slanje..." class="py-2 mt-2">Pošalji</.button>
      </.form>
    <% end %>
    """
  end
end
