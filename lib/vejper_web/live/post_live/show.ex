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

  @impl true
  def handle_event("add_reaction", _params, socket) do
    Social.react(socket.assigns.post, socket.assigns.current_user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_reaction", _params, socket) do
    IO.puts("REMOVE")
    Social.unreact(socket.assigns.post, socket.assigns.current_user)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:comment_added, comment}, socket) do
    post = Map.put(socket.assigns.post, :comments, [comment | socket.assigns.post.comments])
    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_info({:reaction_added, item}, socket) do
    post =
      Map.put(socket.assigns.post, :reactions, socket.assigns.post.reactions + 1)
      |> Map.put(:users, [item.user | socket.assigns.post.users])

    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_info({:reaction_removed, user}, socket) do
    post =
      Map.put(socket.assigns.post, :reactions, socket.assigns.post.reactions - 1)
      |> Map.put(:users, Enum.filter(socket.assigns.post.users, &(&1.id != user.id)))

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

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, Social.get_post!(id))}
  end

  defp page_title(:show), do: "Objava"
  defp page_title(:edit), do: "Uredi objavu"

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :comment_form, to_form(changeset))
  end
end
