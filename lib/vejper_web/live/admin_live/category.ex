defmodule VejperWeb.AdminLive.Category do
  use VejperWeb, :live_view

  alias Vejper.Store
  alias Vejper.Store.Field

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"field_id" => field_id, "id" => id}, _session, socket) do
    category = Store.get_category!(id)
    field = Store.get_field!(field_id)

    assign_stuff(category, field, socket)
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    category = Store.get_category!(id)
    assign_stuff(category, %Field{}, socket)
  end

  def assign_stuff(category, field, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, category)
     |> assign(:field, field)
     |> assign(:category_form, to_form(Store.change_category(category)))}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Store.change_category(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :category_form, to_form(changeset))}
  end

  def handle_event("dropped", %{"id" => "left-" <> id}, socket) do
    fields =
      Enum.filter(socket.assigns.category.fields, fn fi ->
        fi.id != String.to_integer(id)
      end)

    drop(fields, socket)
  end

  def handle_event("dropped", %{"id" => "right-" <> id}, socket) do
    field = Store.get_field!(id)

    fields = [field | socket.assigns.category.fields]
    drop(fields, socket)
  end

  @impl true
  def handle_event("save", %{"category" => category_params}, socket) do
    case Store.update_category(socket.assigns.category, category_params) do
      {:ok, category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kategorija uspešno izmenjena")
         |> assign(:category, category)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :category_form, to_form(changeset))}
    end
  end

  defp drop(fields, socket) do
    socket =
      case Store.assign_fields_to_category(
             socket.assigns.category,
             fields
           ) do
        {:ok, category} ->
          assign(socket, :category, category)

        {:error, error} ->
          IO.inspect(error)
          socket
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Kategorija"
  defp page_title(:edit), do: "Uredi kategoriju"
  defp page_title(:new), do: "Dodaj polje"
  defp page_title(:associate_fields), do: "Dodaj polja"
end
