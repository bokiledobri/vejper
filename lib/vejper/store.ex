defmodule Vejper.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias Vejper.Store.{Query, Category, Field}
  alias Vejper.Repo

  alias Vejper.Store.Ad

  defp store_ads_query() do
    from(a in Ad,
      preload: [user: :profile],
      preload: :images,
      preload: [category: :fields]
    )
  end

  def change_query(%Query{} = query, params \\ %{}) do
    Query.changeset(query, params)
  end

  def get_query_metadata() do
    prices =
      from(a in "store_ads", select: %{min: min(a.price), max: max(a.price)})
      |> Repo.one()

    categories =
      from(c in "store_categories", select: {c.name, c.id})
      |> Repo.all()

    cities =
      from(a in "store_ads", select: a.city, distinct: a.city)
      |> Repo.all()

    states =
      from(a in "store_ads", select: a.state, distinct: a.state)
      |> Repo.all()

    {prices, categories, cities, states}
  end

  def list_ads(meta, %{
        "min_price" => min,
        "max_price" => max,
        "term" => term,
        "category_id" => category_id,
        "city" => city,
        "state" => state
      }) do
    store_query = store_ads_query()

    query =
      from(a in store_query,
        where: a.price >= ^min,
        where: a.price <= ^max,
        order_by: [desc: :inserted_at, desc: :id]
      )

    query =
      if term != "" do
        term = "%#{term}%"
        from(a in query, where: ilike(a.title, ^term))
      else
        query
      end

    query =
      if category_id != "0" do
        from(a in query, where: a.category_id == ^category_id)
      else
        query
      end

    query =
      if city != "Svi" do
        from(a in query, where: a.city == ^city)
      else
        query
      end

    query =
      if state != "Sva" do
        from(a in query, where: a.state == ^state)
      else
        query
      end

    Repo.paginate(query,
      after: meta,
      cursor_fields: [{:inserted_at, :desc}, {:id, :desc}],
      limit: 6
    )
  end

  def list_ads(meta, _params) do
    store_query = store_ads_query()

    from(a in store_query,
      order_by: [desc: :inserted_at, desc: :id]
    )
    |> Repo.paginate(after: meta, cursor_fields: [{:inserted_at, :desc}, {:id, :desc}], limit: 6)
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

  def create_category(name) do
    %Category{}
    |> Category.changeset(%{"name" => name})
    |> Repo.insert()
  end

  def update_category(%Category{} = category, name) do
    category
    |> Category.changeset(%{"name" => name})
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def list_fields() do
    Repo.all(Field) |> Repo.preload(:categories)
  end

  def get_field!(id) do
    Repo.get!(Field, id) |> Repo.preload(:categories)
  end

  def create_field(attrs) do
    %Field{}
    |> Field.changeset(attrs)
    |> Repo.insert()
  end

  def update_field(%Field{} = field, attrs) do
    field
    |> Field.changeset(attrs)
    |> Repo.update()
  end

  def delete_field(%Field{} = field) do
    Repo.delete(field)
  end

  def assign_fields_to_category(%Category{} = category, fields) do
    category
    |> Category.changeset(%{})
    |> Ecto.Changeset.put_assoc(:fields, fields)
    |> Repo.insert()
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
