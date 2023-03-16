defmodule Vejper.Repo.Migrations.AddUsersToChatRooms do
  use Ecto.Migration

  def change do
    create table(:users_chat_rooms) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :chat_room_id, references(:chat_rooms, on_delete: :delete_all)
    end

    alter table(:chat_rooms) do
      add :user_id, references(:users, on_delete: :nilify_all)
    end

    create index(:users_chat_rooms, [:user_id, :chat_room_id])
  end
end
