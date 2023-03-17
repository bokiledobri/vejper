defmodule Vejper.Repo.Migrations.CreateStoreFields do
  use Ecto.Migration

  def change do
    create table(:store_fields) do
      add :name, :string
      add :type, :string
      add :values, {:array, :string}

      timestamps()
    end
  end
end
