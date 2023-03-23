defmodule Vejper.Repo.Migrations.AddMetaFieldsToImages do
  use Ecto.Migration

  def change do
    alter table(:social_images) do
      add :height, :integer
      add :width, :integer
      add :public_id, :string
    end

    alter table(:store_images) do
      add :height, :integer
      add :width, :integer
      add :public_id, :string
    end

    alter table(:profiles) do
      add :profile_image_key, :string
    end
  end
end
