defmodule Vejper.Social.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_reactions" do
    field :type, :string, default: "like"
    belongs_to :post, Vejper.Social.Post
    belongs_to :user, Vejper.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(reaction, attrs \\ %{}) do
    reaction
    |> cast(attrs, [])
  end
end
