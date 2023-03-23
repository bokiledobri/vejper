defmodule Vejper.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias Vejper.Media
  alias Vejper.Repo
  alias Ecto.Multi

  alias Vejper.Social.{Post, Comment, Reaction}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(cursor \\ {NaiveDateTime.utc_now(), 5}) do
    {last_insert, limit} = cursor

    posts =
      from(p in Post,
        preload: [:images, [user: [profile: :image]]],
        order_by: [desc: :inserted_at],
        order_by: [desc: :id],
        left_join: u in assoc(p, :users),
        preload: :users,
        group_by: p.id,
        limit: ^limit,
        where: p.inserted_at < ^last_insert,
        select: %{p | reactions: count(u.id)}
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
    from(p in Post,
      as: :post,
      where: p.id == ^id,
      left_join: u in assoc(p, :users),
      group_by: p.id,
      preload: [user: [profile: :image]],
      preload: :images,
      preload: :users,
      select_merge: %{reactions: count(u.id)}
    )
    |> Repo.one!()
  end

  def create_post(%Vejper.Accounts.User{} = user, attrs \\ %{}, images) do
    changeset =
      user
      |> Ecto.build_assoc(:posts)
      |> Post.changeset(attrs, images)

    case changeset
         |> Repo.insert() do
      {:ok, post} ->
        get_post!(post.id)
        |> broadcast(:post_created)

      error ->
        error
    end
  end

  # @doc """
  # Updates a post.

  ## Examples

  #    iex> update_post(post, %{field: new_value})
  #   {:ok, %Post{}}
  #
  #     iex> update_post(post, %{field: bad_value})
  #    {:error, %Ecto.Changeset{}}

  # """

  #  def update_post(%Post{} = post, attrs) do
  #   case post
  #       |> Repo.preload(:images)
  #      |> Post.changeset(attrs)
  #     |> Repo.update() do
  # {:ok, post} ->
  #  get_post!(post.id)
  # |> broadcast(:post_updated)

  #     error ->
  #      error
  # end
  # end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Enum.each(post.images, fn image -> Media.delete_image(image) end)
    Repo.delete(post)
    broadcast(post, :post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs, nil)
  end

  def list_comments(post_id, cursor \\ {NaiveDateTime.utc_now(), 10}) do
    {last_insert, limit} = cursor

    comments =
      from(c in Comment,
        where: c.post_id == ^post_id,
        order_by: [desc: :inserted_at],
        order_by: [desc: :id],
        preload: [user: [profile: :image]],
        limit: ^limit,
        where: c.inserted_at < ^last_insert
      )
      |> Repo.all()

    last_insert =
      if Enum.count(comments) != 0 do
        Enum.min(Enum.map(comments, fn comment -> comment.inserted_at end), NaiveDateTime)
      else
        last_insert
      end

    %{
      entries: comments,
      meta: {last_insert, limit}
    }
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

  def get_comment!(id) do
    Repo.get!(Comment, id)
  end

  def delete_comment(comment) do
    comment
    |> Repo.delete()
    |> broadcast(:comment_removed)
  end

  def react(%Post{} = post, %Vejper.Accounts.User{} = user) do
    if Enum.find(post.users, fn usr -> usr.id == user.id end) != nil do
      {:error, nil}
    else
      update_assoc =
        %Reaction{}
        |> Reaction.changeset()
        |> Ecto.Changeset.put_assoc(:user, user)
        |> Ecto.Changeset.put_assoc(:post, post)

      Multi.new()
      |> Multi.insert(:update_assoc, update_assoc)
      |> Multi.update_all(
        :update_reactions,
        from(p in Post, where: p.id == ^post.id, select: p.id),
        inc: [reactions: 1]
      )
      |> Repo.transaction()
      |> broadcast(:reaction_added)
    end
  end

  def unreact(%Post{} = post, %Vejper.Accounts.User{} = user) do
    if Enum.find(post.users, fn usr -> usr.id == user.id end) == nil do
      {:error, nil}
    else
      delete_query =
        from(r in Reaction,
          where: r.post_id == ^post.id,
          where:
            r.user_id ==
              ^user.id
        )

      Multi.new()
      |> Multi.delete_all(:delete_query, delete_query)
      |> Multi.update_all(
        :update_reactions,
        from(p in Post, where: p.id == ^post.id, select: p.id),
        inc: [reactions: -1]
      )
      |> Repo.transaction()
      |> broadcast(:reaction_removed)
    end
  end

  def subscribe(id) when is_integer(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "post-" <> Integer.to_string(id))
  end

  def subscribe(id) when is_bitstring(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "post-" <> id)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "posts")
  end

  defp broadcast(%Post{} = post, event) do
    Phoenix.PubSub.broadcast(
      Vejper.PubSub,
      "post-" <> Integer.to_string(post.id),
      {event, post}
    )

    Phoenix.PubSub.broadcast(Vejper.PubSub, "posts", {event, post})

    {:ok, post}
  end

  defp broadcast({:error, _reason} = error, _event) do
    error
  end

  defp broadcast({:ok, %{update_reactions: {_, [post_id | _]}} = multi}, event) do
    Phoenix.PubSub.broadcast(
      Vejper.PubSub,
      "post-" <> Integer.to_string(post_id),
      {event, get_post!(post_id)}
    )

    {:ok, multi}
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
end
