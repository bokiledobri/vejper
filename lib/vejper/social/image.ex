defmodule Vejper.Social.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_images" do
    field :url, :string
    belongs_to :post, Vejper.Social.Post, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
