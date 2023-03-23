defmodule Vejper.Social.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_posts" do
    field :body, :string
    field :title, :string
    belongs_to :user, Vejper.Accounts.User
    has_many :comments, Vejper.Social.Comment

    many_to_many :images, Vejper.Media.Image,
      join_through: "posts_images",
      on_replace: :delete

    many_to_many :users, Vejper.Accounts.User, join_through: Vejper.Social.Reaction
    field :reactions, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(post, attrs, images) do
    post
    |> cast(attrs, [:title, :body, :reactions])
    |> validate_required([:title, :body], message: "obavezno polje")
    |> put_assoc(:images, images)
  end
end
