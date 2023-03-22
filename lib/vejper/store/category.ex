defmodule Vejper.Store.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_categories" do
    field :name, :string

    many_to_many :fields, Vejper.Store.Field,
      join_through: "store_categories_fields",
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
