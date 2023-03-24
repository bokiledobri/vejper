defmodule Vejper.Repo.Migrations.CreateUserCounts do
  use Ecto.Migration

  def change do
    create table(:user_counts) do
      add :count, :integer

      timestamps()
    end
  end
end
