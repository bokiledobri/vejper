defmodule Vejper.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :name, :string
    field :online_users, :integer, virtual: true, default: 0
    belongs_to :user, Vejper.Accounts.User, on_replace: :mark_as_invalid

    many_to_many :users, Vejper.Accounts.User, join_through: "users_chat_rooms"

    has_many :messages, Vejper.Chat.Message, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(room, %{"users" => users} = attrs) do
    room
    |> changeset(attrs)
    |> put_assoc(:users, users)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name], message: "Obavezno polje")
    |> validate_length(:name, max: 12, message: "Najviše 12 znakova")
  end
end
