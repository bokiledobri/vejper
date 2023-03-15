defmodule Vejper.Repo.Migrations.CreateChatRooms do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :name, :string

      timestamps()
    end
  end
end
