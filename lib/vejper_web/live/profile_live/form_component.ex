defmodule VejperWeb.ProfileLive.FormComponent do
  use VejperWeb, :live_component

  alias Vejper.Media
  alias Vejper.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:username]} type="text" label="Korisničko ime" />
        <.input field={@form[:city]} type="text" label="Grad" />
        <%= if @action == :new do %>
          <.input type="date" field={@form[:date_of_birth]} label="Datum rođenja" />
        <% end %>
        <.live_file_input upload={@uploads.avatar} />
        <%= if @uploads.avatar.entries == [] && @current_user.profile do %>
          <div
            :if={@current_user.profile.image}
            class="bg-zinc-100 dark:bg-zinc-900 flex flex-col items-center justify-around"
          >
            <img
              src={@current_user.profile.image.url}
              class="w-[250px] h-[250px] rounded-full"
              alt={@current_user.profile.image.url}
            />
          </div>
        <% end %>
        <%= for entry <- @uploads.avatar.entries do %>
          <div class="bg-zinc-100 dark:bg-zinc-900 flex flex-col gap-3 items-center justify-around">
            <.live_img_preview class="w-[250px] h-[250px] rounded-full" entry={entry} />
            <div class="flex flex-col justify-around gap-2 items-center w-full">
              <progress value={entry.progress} max="100">
                <%= entry.progress %>%
              </progress>
              <.error :for={err <- upload_errors(@uploads.avatar, entry)}>
                <%= error_to_string(err) %>
              </.error>
            </div>
          </div>
        <% end %>

        <:actions>
          <.button phx-disable-with="Čuvanje...">Sačuvaj</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{profile: profile} = assigns, socket) do
    changeset = Accounts.change_profile(profile)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.png .jpg .jpeg), max_entries: 1)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"profile" => profile_params}, socket) do
    changeset =
      socket.assigns.profile
      |> Accounts.change_profile(profile_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"profile" => profile_params}, socket) do
    save_profile(socket, socket.assigns.action, profile_params)
  end

  defp save_profile(socket, :edit, profile_params) do
    [img | _tail] = handle_image(socket)

    case Accounts.update_profile(
           socket.assigns.profile,
           profile_params,
           img
         ) do
      {:ok, profile} ->
        notify_parent({:saved, profile})

        {:noreply,
         socket
         |> put_flash(:info, "Profil uspešno izmenjen")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_profile(socket, :new, profile_params) do
    [img | _tail] = handle_image(socket)

    case Accounts.create_profile(socket.assigns.current_user, profile_params, img) do
      {:ok, profile} ->
        notify_parent({:saved, profile})

        {:noreply,
         socket
         |> put_flash(:info, "Profil uspešno kreiran")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp handle_image(socket) do
    case consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
           Media.upload_image(path)
         end) do
      [] ->
        if socket.assigns.current_user.profile do
          [socket.assigns.current_user.profile.image]
        else
          [%{id: 1, url: "/images/default_avatar.jpg"}]
        end

      rest ->
        rest
    end
  end

  defp error_to_string(:too_large), do: "prevelika slika"
  defp error_to_string(:too_many_files), do: "najviše 1 slika"
  defp error_to_string(:not_accepted), do: "molimo odaberite .png, .jpg ili jpeg format slike"

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
