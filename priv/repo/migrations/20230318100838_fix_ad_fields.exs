defmodule Vejper.Repo.Migrations.FixAdFields do
  use Ecto.Migration

  def change do
    alter table(:store_ads) do
      remove :fields
      add :fields, {:array, :jsonb}, default: []
    end
  end
end
