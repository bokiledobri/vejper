defmodule Vejper.Repo.Migrations.AddSocialReactions do
  use Ecto.Migration

  def change do
    create table(:social_reactions) do
      add :type, :string
      add :user_id, references(:users, on_delete: :nilify_all)
      add :post_id, references(:social_posts, on_delete: :delete_all)
      add :comment_id, references(:social_comments, on_delete: :delete_all)
      timestamps()
    end

    create index(:social_reactions, [:post_id, :user_id, :comment_id])
  end
end
