defmodule Vejper.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:social_posts) do
      add :title, :string
      add :body, :string
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:social_posts, [:user_id])
  end
end
