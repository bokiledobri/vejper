defmodule Vejper.Store.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_images" do
    field :url, :string
    field :public_id, :string
    field :width, :integer
    field :height, :integer
    belongs_to :ad, Vejper.Store.Ad, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url, :public_id, :width, :height])
    |> validate_required([:url])
  end
end
