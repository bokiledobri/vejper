defmodule Vejper.Social.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_posts" do
    field :body, :string
    field :title, :string
    belongs_to :user, Vejper.Accounts.User
    has_many :comments, Vejper.Social.Comment
    has_many :images, Vejper.Social.Image, on_replace: :delete_if_exists
    many_to_many :users, Vejper.Accounts.User, join_through: Vejper.Social.Reaction
    field :reactions, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :reactions])
    |> cast_assoc(:images)
    |> validate_required([:title, :body])
  end
end
