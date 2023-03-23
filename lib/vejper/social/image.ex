defmodule Vejper.Social.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_images" do
    field :url, :string
    field :public_id, :string
    field :width, :integer
    field :height, :integer
    belongs_to :post, Vejper.Social.Post, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url, :width, :height, :public_id])
    |> validate_required([:url])
  end
end
