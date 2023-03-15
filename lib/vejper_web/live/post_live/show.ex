defmodule VejperWeb.PostLive.Show do
  use VejperWeb, :live_view

  alias Vejper.Social

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> assign_form(Social.change_comment(%Social.Comment{}, %{}))
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"comment" => _comment_params}, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    save_comment(socket, comment_params)
  end

  def handle_event("delete", %{"comment" => comment_id}, socket) do
    Social.delete_comment(socket.assigns.post.id, comment_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_reaction", _params, socket) do
    Social.react(socket.assigns.post, socket.assigns.current_user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_reaction", _params, socket) do
    Social.unreact(socket.assigns.post, socket.assigns.current_user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_post", %{"id" => id}, socket) do
    post = Social.get_post!(id)

    if socket.assigns.current_user.id == post.user.id do
      {:ok, _} = Social.delete_post(post)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("image-prev", _params, socket) do
    index =
      if socket.assigns.active_image_index == 0 do
        Enum.count(socket.assigns.post.images) - 1
      else
        socket.assigns.active_image_index - 1
      end

    socket =
      assign(socket, :active_image_index, index)
      |> assign(:active_image, Enum.at(socket.assigns.post.images, index))

    {:noreply, socket}
  end

  @impl true
  def handle_event("image-next", _params, socket) do
    index =
      if socket.assigns.active_image_index == Enum.count(socket.assigns.post.images) - 1 do
        0
      else
        socket.assigns.active_image_index + 1
      end

    socket =
      assign(socket, :active_image_index, index)
      |> assign(:active_image, Enum.at(socket.assigns.post.images, index))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:comment_added, comment}, socket) do
    post = Map.put(socket.assigns.post, :comments, [comment | socket.assigns.post.comments])
    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_info({:reaction_added, post}, socket) do
    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_info({:reaction_removed, post}, socket) do
    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_info({:post_deleted, _post}, socket) do
    socket =
      put_flash(socket, :info, "Objava koju ste gledali upravo je obrisana")
      |> redirect(to: ~p"/posts")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    socket =
      socket
      |> assign(:active_image, Enum.at(post.images, 0))
      |> assign(:active_image_index, 0)

    {:noreply, assign(socket, :post, post)}
  end

  defp save_comment(socket, comment_params) do
    case Social.create_comment(socket.assigns.post, socket.assigns.current_user, comment_params) do
      {:ok, _comment} ->
        socket =
          socket
          |> push_event("clear-input", %{id: "comment-input"})

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if connected?(socket), do: Social.subscribe(id)
    post = Social.get_post!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:active_image, Enum.at(post.images, 0))
     |> assign(:active_image_index, 0)
     |> assign(:post, post)}
  end

  defp page_title(:show), do: "Objava"
  defp page_title(:edit), do: "Uredi objavu"

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :comment_form, to_form(changeset))
  end
end
