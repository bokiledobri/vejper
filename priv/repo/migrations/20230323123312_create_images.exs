defmodule Vejper.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :url, :string
      add :width, :integer
      add :height, :integer
      add :public_id, :string

      timestamps()
    end
  end
end
