defmodule Vejper.Repo.Migrations.ReworkImageHandling do
  use Ecto.Migration

  def change do
    drop(index(:store_images, [:ad_id]))
    drop(table(:store_images))
    drop(index(:social_images, [:post_id]))
    drop(table(:social_images))

    create table(:ads_images) do
      add(:ad_id, references(:store_ads, on_delete: :delete_all))
      add(:image_id, references(:images, on_delete: :delete_all))
    end

    create(unique_index(:ads_images, [:ad_id, :image_id]))

    create table(:posts_images) do
      add(:post_id, references(:social_posts, on_delete: :delete_all))
      add(:image_id, references(:images, on_delete: :delete_all))
    end

    create(unique_index(:posts_images, [:post_id, :image_id]))

    alter table(:profiles) do
      remove(:profile_image_url)
      remove(:profile_image_key)
      add(:image_id, references(:images, on_delete: :nilify_all))
    end

    create(index(:profiles, [:image_id]))

    Vejper.Repo.insert!(%Vejper.Media.Image{
      url: "/images/default_avatar.jpg",
      public_id: "local",
      width: 600,
      height: 600
    })
  end
end
