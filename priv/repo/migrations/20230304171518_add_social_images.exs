defmodule Vejper.Repo.Migrations.AddSocialImages do
  use Ecto.Migration

  def change do
    create table(:social_images) do
      add :url, :string
      add :post_id, references(:social_posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:social_images, [:post_id])
  end
end
