defmodule Vejper.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :username, :string
      add :city, :string
      add :date_of_birth, :date
      add :profile_image_url, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:profiles, [:user_id])
    create unique_index(:profiles, [:username])

    alter table(:users) do
      add :role, :string
    end
  end
end
