defmodule Vejper.Repo.Migrations.CreateStoreImages do
  use Ecto.Migration

  def change do
    create table(:store_images) do
      add :url, :string
      add :ad_id, references(:store_ads, on_delete: :delete_all)

      timestamps()
    end

    create index(:store_images, [:ad_id])
  end
end
