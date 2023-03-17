defmodule Vejper.Store.Field do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_fields" do
    field :name, :string
    field :type, :string
    field :values, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(field, attrs) do
    field
    |> cast(attrs, [:name, :type, :values])
    |> validate_required([:name, :type, :values])
  end
end
