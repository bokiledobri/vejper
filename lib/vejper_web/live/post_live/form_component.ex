defmodule VejperWeb.PostLive.FormComponent do
  use VejperWeb, :live_component

  alias Vejper.Social

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <header>
        <%= @title %>
      </header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Naslov" />
        <.input field={@form[:body]} type="textarea" label="Tekst" />
        <.live_file_input upload={@uploads.images} label="Slike" />
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
        <:actions>
          <.button phx-disable-with="Objavi...">Objavi</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Social.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)
     |> assign(:images, post.images)
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
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Social.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  #  defp save_post(socket, :edit, post_params) do
  #   if socket.assigns.current_user.id == socket.assigns.post.user.id do
  #    old_images =
  #     Enum.map(socket.assigns.images, fn img -> %{"id" => img.id, "url" => img.url} end)
  #
  #     new_images = Enum.map(handle_images(socket), fn img -> %{"url" => img} end)
  #
  #      post_params =
  #        Map.put(
  #          post_params,
  #          "images",
  #          Enum.concat(new_images, old_images)
  #        )
  #
  #      case Social.update_post(socket.assigns.post, post_params) do
  #        {:ok, _post} ->
  #          {:noreply,
  #           socket
  #           |> put_flash(:info, "Objava uspešno izmenjena")
  #           |> push_patch(to: socket.assigns.patch)}
  #
  #        {:error, %Ecto.Changeset{} = changeset} ->
  #          {:noreply, assign_form(socket, changeset)}
  #      end
  #    else
  #      socket
  #    end
  #  end

  defp save_post(socket, :new, post_params) do
    case Social.create_post(socket.assigns.current_user, post_params, handle_images(socket)) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Uspešna objava")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp handle_images(socket) do
    consume_uploaded_entries(socket, :images, fn %{path: path}, _entry ->
      Cloudex.upload(path)
    end)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp error_to_string(:too_large), do: "prevelike slike"
  defp error_to_string(:too_many_files), do: "najviše 10 slika"
  defp error_to_string(:not_accepted), do: "molimo odaberite .png, .jpg ili jpeg format slika"
end
