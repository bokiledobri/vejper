defmodule Vejper.Social.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_comments" do
    field :body, :string
    belongs_to :post, Vejper.Social.Post
    belongs_to :user, Vejper.Accounts.User
    many_to_many :users, Vejper.Accounts.User, join_through: Vejper.Social.Reaction
    field :reactions, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body], message: "prazan komentar")
  end
end
