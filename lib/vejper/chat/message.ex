defmodule Vejper.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :state, :string, default: "alive"
    field :body, :string
    belongs_to :user, Vejper.Accounts.User
    belongs_to :room, Vejper.Chat.Room

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :state])
    |> validate_required([:body], message: "Prazna poruka")
    |> validate_length(:body, max: 255, message: "Najviše 255 znakova")
  end
end
