defmodule Vejper.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias Vejper.Repo

  alias Vejper.Social.{Post, Comment, Reaction}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(cursor \\ {NaiveDateTime.utc_now(), 3}) do
    {last_insert, limit} = cursor

    posts =
      from(p in Post,
        preload: [user: :profile],
        preload: :images,
        order_by: [desc: :inserted_at],
        limit: ^limit,
        where: p.inserted_at < ^last_insert,
        select: p
      )
      |> Repo.all()

    last_insert =
      if Enum.count(posts) != 0 do
        Enum.min(Enum.map(posts, fn post -> post.inserted_at end), NaiveDateTime)
      else
        last_insert
      end

    %{
      entries: posts,
      meta: {last_insert, limit}
    }
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    comments = from c in Comment, order_by: [desc: :inserted_at], preload: [user: :profile]

    from(p in Post,
      as: :post,
      where: p.id == ^id,
      left_join: u in assoc(p, :users),
      group_by: p.id,
      preload: [user: :profile],
      preload: :images,
      preload: [comments: ^comments],
      preload: :users,
      select_merge: %{reactions: count(u.id)}
    )
    |> Repo.one()
  end

  def create_post(%Vejper.Accounts.User{} = user, attrs \\ %{}) do
    case user
         |> Ecto.build_assoc(:posts)
         |> Post.changeset(attrs)
         |> Repo.insert() do
      {:ok, post} ->
        {:ok, post |> Repo.preload([:images, [user: :profile]])}

      error ->
        error
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Repo.preload(:images)
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  def create_comment(%Post{} = post, %Vejper.Accounts.User{} = user, attrs) do
    post
    |> Ecto.build_assoc(:comments)
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
    |> broadcast(:comment_added)
  end

  def react(%Post{} = post, %Vejper.Accounts.User{} = user) do
    %Reaction{}
    |> Reaction.changeset()
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Repo.insert()
    |> broadcast(:reaction_added)
  end

  def unreact(%Post{} = post, %Vejper.Accounts.User{} = user) do
    from(r in Reaction,
      where: r.post_id == ^post.id,
      where:
        r.user_id ==
          ^user.id
    )
    |> Repo.delete_all()

    broadcast(:reaction_removed, post.id, user)
  end

  def subscribe(id) when is_integer(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "post-" <> Integer.to_string(id))
  end

  def subscribe(id) when is_bitstring(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "post-" <> id)
  end

  defp broadcast({:error, _reason} = error, _event) do
    error
  end

  defp broadcast({:ok, item}, event) do
    item = Repo.preload(item, [:post, user: [:profile]])

    Phoenix.PubSub.broadcast(
      Vejper.PubSub,
      "post-" <> Integer.to_string(item.post.id),
      {event, item}
    )

    {:ok, item}
  end

  defp broadcast(event, id, user) do
    Phoenix.PubSub.broadcast(
      Vejper.PubSub,
      "post-" <> Integer.to_string(id),
      {event, user}
    )

    {1, nil}
  end
end
