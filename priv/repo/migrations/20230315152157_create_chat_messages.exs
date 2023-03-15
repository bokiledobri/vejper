defmodule Vejper.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :text, :string
      add :state, :string
      add :room_id, references(:chat_rooms, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:chat_messages, [:room_id])
    create index(:chat_messages, [:user_id])
  end
end
