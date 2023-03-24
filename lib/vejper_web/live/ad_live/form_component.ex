defmodule VejperWeb.AdLive.FormComponent do
  use VejperWeb, :live_component

  alias Vejper.Accounts
  alias Vejper.Media
  alias Vejper.Store.Category
  alias Vejper.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@banned} class="z-50 p-5 w-full h-full bg-white dark:bg-black">
        Vaš nalog je suspendovan od strane
        <.link navigate={~p"/profil/#{@banned.by.profile.id}"} class="font-bold">
          <%= @banned.by.profile.username %>
        </.link>
        i ne možete postavljati oglase do <%= humanize_datetime(@banned.until) %>
      </div>
      <.simple_form
        :if={!@banned}
        for={@form}
        id="ad-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:category_id]}
          type="select"
          phx-change="validate"
          options={@categories}
          label="Kategorija"
        />
        <.inputs_for :let={field} field={@form[:fields]}>
          <.input
            field={field[:value]}
            type={field.params["type"]}
            options={field.params["values"]}
            label={field.params["name"]}
          />
        </.inputs_for>
        <.input field={@form[:title]} type="text" label="Naslov" />
        <.input field={@form[:description]} type="textarea" label="Opis" />
        <.input field={@form[:price]} type="number" label="Cena" />
        <.input field={@form[:city]} type="text" label="Grad" />
        <.input
          field={@form[:state]}
          type="select"
          label="Stanje"
          options={[
            "Novo",
            "Samo probano",
            "Korišćeno",
            "Vidljivi tragovi korišćenja",
            "Oštećeno",
            "Neupotrebljivo"
          ]}
        />
        <.live_file_input upload={@uploads.images} label="Slike" />
        <div class="flex flex-col md:flex-row md:flex-wrap gap-4">
          <%= if is_list(@images) do %>
            <%= for entry <- @images do %>
              <div class="relative bg-zinc-100 dark:bg-zinc-900 w-[250px] flex flex-col md:flex-row md:flex-wrap items-center justify-around">
                <div class="absolute top-6 right-5">
                  <button
                    phx-click="remove-entry"
                    phx-value-id={entry.id}
                    phx-target={@myself}
                    type="button"
                    class="-m-3 flex-none p-3 opacity-60 hover:opacity-80"
                    aria-label={gettext("close")}
                  >
                    <Heroicons.x_mark solid class="h-10 w-10 stroke-current" />
                  </button>
                </div>
                <img class="w-[250px] h-[250px]" src={entry.url} />
                <div class="flex flex-col justify-around items-center w-full"></div>
              </div>
            <% end %>
          <% end %>
          <%= for entry <- @uploads.images.entries do %>
            <div class="relative bg-zinc-100 dark:bg-zinc-900 w-[250px] flex flex-col md:flex-row md:flex-wrap items-center justify-around">
              <div class="absolute top-6 right-5">
                <button
                  phx-click="remove-entry"
                  phx-value-ref={entry.ref}
                  phx-target={@myself}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-60 hover:opacity-80"
                  aria-label={gettext("close")}
                >
                  <Heroicons.x_mark solid class="h-10 w-10 stroke-current" />
                </button>
              </div>
              <.live_img_preview class="w-[250px] h-[250px]" entry={entry} />
              <div class="flex flex-col justify-around items-center w-full">
                <progress value={entry.progress} max="100">
                  <%= entry.progress %>%
                </progress>
                <.error :for={err <- upload_errors(@uploads.images, entry)}>
                  <%= error_to_string(err) %>
                </.error>
              </div>
            </div>
          <% end %>
        </div>
        <:actions>
          <.button phx-disable-with="Čuvanje...">Sačuvaj</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ad: ad} = assigns, socket) do
    categories = Store.list_categories()

    category =
      with %Category{} <- ad.category do
        ad.category
      else
        _ ->
          Enum.at(categories, 0)
      end

    fields = category.fields
    categories = categories |> Enum.map(fn c -> {c.name, c.id} end)
    city = if ad.city == nil, do: assigns.current_user.profile.city, else: ad.city

    ad = Map.put(ad, :city, city)
    changeset = Store.change_ad(ad, category)

    socket =
      assign(socket, :uploaded_files, [])
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)
      |> assign(assigns)
      |> assign(:categories, categories)
      |> assign(:fields, fields)
      |> assign(:banned, Accounts.banned?(assigns.current_user.id, "store"))
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("remove-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("remove-entry", %{"id" => id}, socket) do
    images = Enum.filter(socket.assigns.images, fn img -> Integer.to_string(img.id) != id end)

    {:noreply, assign(socket, :images, images)}
  end

  @impl true
  def handle_event("validate", %{"ad" => ad_params}, socket) do
    category = Store.get_category!(ad_params["category_id"])

    category =
      if category == nil do
        Enum.at(socket.assigns.categories, 0)
      else
        category
      end

    changeset =
      socket.assigns.ad
      |> Store.change_ad(ad_params, category)
      |> Map.put(:action, :validate)

    socket = assign_form(socket, changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"ad" => ad_params}, socket) do
    if !socket.assigns.banned do
      category = Store.get_category!(ad_params["category_id"])
      save_ad(socket, socket.assigns.action, ad_params, category)
    else
      {:noreply, socket}
    end
  end

  defp save_ad(socket, :edit, ad_params, category) do
    if owner?(socket.assigns.ad, socket) do
      case Store.update_ad(
             socket.assigns.ad,
             ad_params,
             category,
             Enum.concat(socket.assigns.images, handle_images(socket))
           ) do
        {:ok, _ad} ->
          {:noreply,
           socket
           |> put_flash(:info, "Oglas uspešno izmenjen")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp save_ad(socket, :new, ad_params, category) do
    case Store.create_ad(
           socket.assigns.current_user.id,
           ad_params,
           category,
           handle_images(socket)
         ) do
      {:ok, _ad} ->
        {:noreply,
         socket
         |> put_flash(:info, "Oglas uspešno objavljen")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp handle_images(socket) do
    consume_uploaded_entries(socket, :images, fn %{path: path}, _entry ->
      Media.upload_image(path)
    end)
  end

  defp error_to_string(:too_large), do: "prevelike slike"
  defp error_to_string(:too_many_files), do: "najviše 10 slika"
  defp error_to_string(:not_accepted), do: "molimo odaberite .png, .jpg ili jpeg format slika"

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset)
    assign(socket, :form, form)
  end
end
