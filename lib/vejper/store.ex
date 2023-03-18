defmodule Vejper.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias Vejper.Store.Category
  alias Vejper.Repo

  alias Vejper.Store.Ad

  @doc """
  Returns the list of store_ads.

  ## Examples

      iex> list_store_ads()
      [%Ad{}, ...]

  """
  def list_store_ads do
    from(a in Ad,
      preload: [user: :profile],
      preload: :images,
      preload: [category: :fields]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ad!(id),
    do: Repo.get!(Ad, id) |> Repo.preload([:images, [user: :profile], [category: :fields]])

  @doc """
  Creates a ad.

  ## Examples

      iex> create_ad(%{field: value})
      {:ok, %Ad{}}

      iex> create_ad(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ad(user_id, attrs \\ %{}, %Category{} = category) do
    Vejper.Accounts.get_user!(user_id)
    |> Ecto.build_assoc(:ads)
    |> Ad.changeset(attrs, category)
    |> Repo.insert()
    |> broadcast(:ad_created, :all)
  end

  @doc """
  Updates a ad.

  ## Examples

      iex> update_ad(ad, %{field: new_value})
      {:ok, %Ad{}}

      iex> update_ad(ad, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ad(%Ad{} = ad, attrs, %Category{} = category) do
    ad
    |> Ad.changeset(attrs, category)
    |> Repo.update()
    |> broadcast(:ad_updated, :all)
    |> broadcast(:ad_updated)
  end

  @doc """
  Deletes a ad.

  ## Examples

      iex> delete_ad(ad)
      {:ok, %Ad{}}

      iex> delete_ad(ad)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ad(%Ad{} = ad) do
    Repo.delete(ad)
    |> broadcast(:ad_deleted, :all)
    |> broadcast(:ad_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ad changes.

  ## Examples

      iex> change_ad(ad)
      %Ecto.Changeset{data: %Ad{}}

  """
  def change_ad(%Ad{} = ad, attrs \\ %{}, category) do
    Ad.changeset(ad, attrs, category)
  end

  def list_categories() do
    Repo.all(Category) |> Repo.preload(:fields)
  end

  def get_category!(id) do
    Repo.get!(Category, id) |> Repo.preload(:fields)
  end

  def subscribe(id) when is_integer(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "ad-" <> Integer.to_string(id))
  end

  def subscribe(id) when is_bitstring(id) do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "ad-" <> id)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Vejper.PubSub, "ads")
  end

  defp broadcast({:error, _} = error, _), do: error

  defp broadcast({:ok, %Ad{} = ad} = return, event) do
    Phoenix.PubSub.broadcast(Vejper.PubSub, "ad-" <> Integer.to_string(ad.id), {event, ad})
    return
  end

  defp broadcast({:error, _} = error, _, :all), do: error

  defp broadcast({:ok, %Ad{} = ad} = return, event, :all) do
    Phoenix.PubSub.broadcast(
      Vejper.PubSub,
      "ads",
      {event, Repo.preload(ad, [:images, [user: :profile]])}
    )

    return
  end

  defp broadcast({:ok, item} = return, event, :all) do
    Phoenix.PubSub.broadcast(Vejper.PubSub, "ads", {event, item})
    return
  end
end
