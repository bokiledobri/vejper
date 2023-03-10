defmodule Vejper.Repo.Migrations.IncreaseBodyCharSizes do
  use Ecto.Migration

  def change do
    alter table(:social_posts) do
      modify :body, :string, size: 4096
    end

    alter table(:social_comments) do
      modify :body, :string, size: 4096
    end
  end
end
