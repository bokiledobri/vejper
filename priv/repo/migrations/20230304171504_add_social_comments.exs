defmodule Vejper.Repo.Migrations.AddSocialComments do
  use Ecto.Migration

  def change do
    create table(:social_comments) do
      add(:body, :string)
      add(:user_id, references(:users, on_delete: :nilify_all))
      add(:post_id, references(:social_posts, on_delete: :delete_all))

      timestamps()
    end

    create(index(:social_comments, [:post_id, :user_id]))
  end
end
