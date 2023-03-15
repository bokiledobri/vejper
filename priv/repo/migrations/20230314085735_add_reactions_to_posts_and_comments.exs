defmodule Vejper.Repo.Migrations.AddReactionsToPostsAndComments do
  use Ecto.Migration

  def change do
    alter table(:social_posts) do
      add :reactions, :integer
    end

    alter table(:social_comments) do
      add :reactions, :integer
    end
  end
end
