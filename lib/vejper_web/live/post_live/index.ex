defmodule VejperWeb.PostLive.Index do
  use VejperWeb, :live_view

  alias Vejper.Social
  alias Vejper.Social.Post

  @impl true
  def mount(_params, _session, socket) do
    %{entries: posts, meta: meta} = Social.list_posts()

    socket =
      socket
      |> assign(:uploaded_files, [])
      |> assign(:meta, meta)
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)

    {:ok, stream(socket, :posts, posts, dom_id: &"post- #{&1.id}")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Uredi objavu")
    |> assign(:post, Social.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova objava")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Najnovije objave")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({VejperWeb.PostLive.FormComponent, {:saved, _post}}, socket) do
    %{entries: posts, meta: meta} = Social.list_posts()

    socket =
      Enum.reduce(posts, socket, fn post, socket ->
        socket
        |> stream_insert(:posts, post)
      end)

    {:noreply, assign(socket, :meta, meta)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Social.get_post!(id)

    if socket.assigns.current_user.id == post.user.id do
      {:ok, _} = Social.delete_post(post)

      {:noreply, stream_delete(socket, :posts, post)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("load-more", _params, socket) do
    %{entries: posts, meta: meta} = Social.list_posts(socket.assigns.meta)

    socket =
      Enum.reduce(posts, socket, fn post, socket ->
        socket
        |> stream_insert(:posts, post)
      end)
      |> assign(:uploaded_files, [])
      |> assign(:meta, meta)
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg), max_entries: 10)

    {:noreply, socket}
  end
end
