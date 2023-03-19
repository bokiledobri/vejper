defmodule Vejper.Meta.Lists do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:name, :string, []}
  schema "meta_lists" do
    field :items, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(lists, attrs) do
    lists
    |> cast(attrs, [:name, :items])
    |> validate_required([:name, :items])
  end
end
