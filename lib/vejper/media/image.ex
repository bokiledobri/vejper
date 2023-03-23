defmodule Vejper.Media.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :height, :integer
    field :public_id, :string
    field :url, :string
    field :width, :integer

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url, :width, :height, :public_id])
    |> validate_required([:url, :width, :height, :public_id])
  end
end
