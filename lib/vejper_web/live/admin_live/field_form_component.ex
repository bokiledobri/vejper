defmodule VejperWeb.Admin.FieldFormComponent do
  use VejperWeb, :live_component

  alias Vejper.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="field-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Naziv" />
        <.input field={@form[:type]} type="select" label="Tip" options={["text", "select", "number"]} />
        <.input
          :if={!(@form[:type].value != "select")}
          field={@form[:values]}
          type="text"
          label="Moguće vrednosti"
        />
        <:actions>
          <.button phx-disable-with="Čuvanje...">Sačuvaj</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{field: field} = assigns, socket) do
    changeset = Store.change_field(field)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"field" => field_params}, socket) do
    changeset =
      socket.assigns.field
      |> Store.change_field(field_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"field" => field_params}, socket) do
    save_field(socket, socket.assigns.action, field_params)
  end

  defp save_field({:ok, field}, message, socket) do
    notify_parent({:saved, field})

    {:noreply,
     socket
     |> put_flash(:info, message)
     |> push_patch(to: socket.assigns.patch)}
  end

  defp save_field({:error, %Ecto.Changeset{} = changeset}, _message, socket) do
    {:noreply, assign_form(socket, changeset)}
  end

  defp save_field(socket, :edit, field_params) do
    save_field(
      Store.update_field(socket.assigns.field, field_params),
      "Polje uspešno izmenjeno",
      socket
    )
  end

  defp save_field(%{assigns: %{category: category}} = socket, :new, field_params) do
    save_field(Store.create_field(category, field_params), "Polje uspešno kreirano", socket)
  end

  defp save_field(socket, :new, field_params) do
    save_field(Store.create_field(field_params), "Polje uspešno kreirano", socket)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset) |> trans_form)
  end

  defp trans_form(%{data: %{values: values}, source: %{data: _data}} = form)
       when is_list(values) do
    values = Enum.join(values, ", ")

    Map.put(form, :data, Map.put(form.data, :values, values))
    |> Map.put(:source, Map.put(form.source, :data, Map.put(form.source.data, :values, values)))
    |> trans_form
  end

  defp trans_form(%{params: %{"values" => values}, source: %{changes: changes}} = form)
       when is_list(values) do
    values = Enum.join(values, ", ")
    params = Map.put(form.params, "values", values)
    changes = Map.put(changes, :values, values)

    form =
      Map.put(form, :params, params)
      |> Map.put(:source, Map.put(form.source, :changes, changes))

    form
  end

  defp trans_form(form) do
    form
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
