defmodule Vejper.Repo.Migrations.AddMetaFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :chat_banned_until, :naive_datetime
      add :ads_banned_until, :naive_datetime
      add :mods, {:array, :string}
    end
  end
end
