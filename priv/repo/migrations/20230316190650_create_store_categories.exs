defmodule Vejper.Repo.Migrations.CreateStoreCategories do
  use Ecto.Migration

  def change do
    create table(:store_categories) do
      add :name, :string

      timestamps()
    end

    alter table(:store_ads) do
      add :category_id, references(:store_categories, on_delete: :nilify_all)
    end

    create index(:store_ads, [:category_id])
  end
end
