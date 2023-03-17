defmodule VejperWeb.AdLive.FormComponent do
  use VejperWeb, :live_component

  alias Vejper.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="ad-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
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
    city = if ad.city == nil, do: assigns.current_user.profile.city, else: ad.city
    ad = Map.put(ad, :city, city)
    changeset = Store.change_ad(ad)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
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
    changeset =
      socket.assigns.ad
      |> Store.change_ad(ad_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"ad" => ad_params}, socket) do
    save_ad(socket, socket.assigns.action, ad_params)
  end

  defp save_ad(socket, :edit, ad_params) do
    ad_params =
      Map.put(
        ad_params,
        "images",
        Enum.map(handle_images(socket), fn img -> %{"url" => img} end)
      )

    case Store.update_ad(socket.assigns.ad, ad_params) do
      {:ok, _ad} ->
        {:noreply,
         socket
         |> put_flash(:info, "Oglas uspešno izmenjen")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_ad(socket, :new, ad_params) do
    ad_params =
      Map.put(
        ad_params,
        "images",
        Enum.map(handle_images(socket), fn img -> %{"url" => img} end)
      )

    case Store.create_ad(socket.assigns.current_user.id, ad_params) do
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
      dest =
        Path.join([
          File.cwd!(),
          "priv",
          "static",
          "store",
          Integer.to_string(socket.assigns.current_user.id) <> Path.basename(path)
        ])

      File.cp!(path, dest)

      {:ok, ~p"/store/#{Path.basename(dest)}"}
    end)
  end

  defp error_to_string(:too_large), do: "prevelike slike"
  defp error_to_string(:too_many_files), do: "najviše 10 slika"
  defp error_to_string(:not_accepted), do: "molimo odaberite .png, .jpg ili jpeg format slika"

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
