defmodule Vejper.Repo.Migrations.FixChatMessages do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      remove :text
      add :body, :string
    end
  end
end
