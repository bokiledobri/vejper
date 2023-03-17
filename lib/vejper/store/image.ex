defmodule Vejper.Store.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_images" do
    field :url, :string
    field :ad_id, :id

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
