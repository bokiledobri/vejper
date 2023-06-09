defmodule Vejper.Social.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_comments" do
    field :body, :string
    belongs_to :post, Vejper.Social.Post
    belongs_to :user, Vejper.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body], message: "prazan komentar")
    |> validate_length(:body, max: 255, message: "Najviše 255 znakova")
  end
end
