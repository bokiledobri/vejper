defmodule Vejper.Store.Ad do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_ads" do
    field :city, :string
    field :description, :string
    field :fields, {:map, :string}
    field :price, :integer
    field :state, :string
    field :title, :string
    belongs_to :user, Vejper.Accounts.User, on_replace: :nilify
    has_many :images, Vejper.Store.Image

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [:title, :description, :price, :city, :fields, :state])
    |> cast_assoc(:images)
    |> validate_required([:title, :price, :city, :state], message: "Obavezno polje")
  end
end
