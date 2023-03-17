defmodule Vejper.Repo.Migrations.AddCategoriesFields do
  use Ecto.Migration

  def change do
    create table(:store_categories_fields) do
      add :category_id, references(:store_categories), on_delete: :delete_all
      add :field_id, references(:store_fields), on_delete: :delete_all
    end

    create index(:store_categories_fields, [:category_id, :field_id], unique: true)
  end
end
