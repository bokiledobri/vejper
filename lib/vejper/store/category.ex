defmodule Vejper.Store.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_categories" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
