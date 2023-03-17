defmodule Vejper.Repo.Migrations.CreateStoreAds do
  use Ecto.Migration

  def change do
    create table(:store_ads) do
      add :title, :string
      add :description, :text
      add :price, :integer
      add :city, :text
      add :fields, {:map, :string}
      add :state, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:store_ads, [:user_id])
  end
end
