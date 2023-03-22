defmodule Vejper.Store.Field do
  alias Vejper.Store.Category
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_fields" do
    field :name, :string
    field :type, :string
    field :values, {:array, :string}
    many_to_many :categories, Vejper.Store.Category, join_through: "store_categories_fields"

    timestamps()
  end

  @doc false
  def changeset(field, %{"values" => values} = attrs) when is_bitstring(values) do
    attrs = Map.put(attrs, "values", String.split(values, ", "))

    field
    |> cast(attrs, [:name, :type, :values])
    |> validate_required([:name, :type], message: "Obavezno polje")
  end

  @doc false
  def changeset(field, attrs) do
    field
    |> cast(attrs, [:name, :type, :values])
    |> validate_required([:name, :type], message: "Obavezno polje")
  end

  @doc false
  def changeset(field, %{"values" => values} = attrs, %Category{} = category)
      when is_bitstring(values) do
    attrs = Map.put(attrs, "values", String.split(values, ", "))

    field
    |> cast(attrs, [:name, :type, :values])
    |> put_assoc(:categories, [category | field.categories])
    |> validate_required([:name, :type], message: "Obavezno polje")
  end

  @doc false
  def changeset(field, attrs, %Category{} = category) do
    field
    |> cast(attrs, [:name, :type, :values])
    |> put_assoc(:categories, [category | field.categories])
    |> validate_required([:name, :type], message: "Obavezno polje")
  end
end
