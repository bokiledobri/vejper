defmodule Vejper.MediaTest do
  use Vejper.DataCase

  alias Vejper.Media

  describe "images" do
    alias Vejper.Media.Image

    import Vejper.MediaFixtures

    @invalid_attrs %{height: nil, public_id: nil, url: nil, width: nil}

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Media.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Media.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      valid_attrs = %{height: 42, public_id: "some public_id", url: "some url", width: 42}

      assert {:ok, %Image{} = image} = Media.create_image(valid_attrs)
      assert image.height == 42
      assert image.public_id == "some public_id"
      assert image.url == "some url"
      assert image.width == 42
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      update_attrs = %{height: 43, public_id: "some updated public_id", url: "some updated url", width: 43}

      assert {:ok, %Image{} = image} = Media.update_image(image, update_attrs)
      assert image.height == 43
      assert image.public_id == "some updated public_id"
      assert image.url == "some updated url"
      assert image.width == 43
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_image(image, @invalid_attrs)
      assert image == Media.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Media.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Media.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Media.change_image(image)
    end
  end
end
