defmodule Vejper.Store.Query do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :min_price, :integer
    field :max_price, :integer
    field :term, :string
    field :city, :string
    field :state, :string
    field :category_id, :integer
  end

  def changeset(query, attrs) do
    query
    |> cast(attrs, [:min_price, :max_price, :term, :city, :state, :category_id])
  end
end
