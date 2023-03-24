defmodule Vejper.Repo.Migrations.CreateBans do
  use Ecto.Migration

  def change do
    create table(:bans) do
      add :until, :naive_datetime
      add :type, :string
      add :banned_id, references(:users, on_delete: :delete_all)
      add :by_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:bans, [:banned_id])
    create index(:bans, [:by_id])
    create unique_index(:bans, [:banned_id, :type])
  end
end
